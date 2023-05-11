import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Buffer "mo:base/Buffer";
import Principal "mo:base/Principal";

module IC {
    public type CanisterId = Principal;
    public type CanisterSettings = {
        controllers : [Principal];
        compute_allocation : Nat;
        memory_allocation : Nat;
        freezing_threshold : Nat;
    };
    public type CanisterStatus = {
        status : { #running; #stopping; #stopped };
        settings : CanisterSettings;
        module_hash : ?Blob;
        memory_size : Nat;
        cycles : Nat;
        idle_cycles_burned_per_day : Nat;
    };

    public type ManagementCanister = actor {
        create_canister : ({ settings : ?CanisterSettings }) -> async ({
            canister_id : CanisterId;
        });
        install_code : ({
            mode : { #install; #reinstall; #upgrade };
            canister_id : CanisterId;
            wasm_module : Blob;
            arg : Blob;
        }) -> async ();
        update_settings : ({
            canister_id : CanisterId;
            settings : CanisterSettings;
        }) -> async ();
        deposit_cycles : ({ canister_id : Principal }) -> async ();
        canister_status : ({ canister_id : CanisterId }) -> async (CanisterStatus);
    };

    /// Parses the controllers from the error returned by canister status when the caller is not the controller
    /// Of the canister it is calling
    ///
    /// TODO: This is a temporary solution until the IC exposes this information.
    /// TODO: Note that this is a pretty fragile text parsing solution (check back in periodically for better solution)
    ///
    /// Example error message:
    ///
    /// "Only the controllers of the canister r7inp-6aaaa-aaaaa-aaabq-cai can control it.
    /// Canister's controllers: rwlgt-iiaaa-aaaaa-aaaaa-cai 7ynmh-argba-5k6vi-75frw-kfqpa-3xtca-nmzk3-hrmvb-fydxk-w4a4k-2ae
    /// Sender's ID: rkp4c-7iaaa-aaaaa-aaaca-cai"
    public func parseControllersFromCanisterStatusErrorIfCallerNotController(errorMessage : Text) : [Principal] {
        let lines = Iter.toArray(Text.split(errorMessage, #text("\n")));
        let words = Iter.toArray(Text.split(lines[1], #text(" ")));
        var i = 2;
        let controllers = Buffer.Buffer<Principal>(0);

        while (i < words.size()) {
            controllers.add(Principal.fromText(words[i]));
            i += 1;
        };

        Buffer.toArray<Principal>(controllers);
    };
};
