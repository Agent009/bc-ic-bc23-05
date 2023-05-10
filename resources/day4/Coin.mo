import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Option "mo:base/Option";
import Nat8 "mo:base/Nat8";
import Principal "mo:base/Principal";
import Hash "mo:base/Hash";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";

module Coin {
    public type Subaccount = Blob;
    public type Account = {
        owner : Principal;
        subaccount : ?Subaccount;
    };

    func _getDefaultSubaccount() : Subaccount {
        Blob.fromArrayMut(Array.init(32, 0 : Nat8));
    };

    public func getAccountFromPrincipal(principal : Principal) : Account {
        return {
            owner = principal;
            subaccount = Option.make(_getDefaultSubaccount());
        };
    };

    public func accountsEqual(lhs : Account, rhs : Account) : Bool {
        // Debug.print("accountsEqual() - lhs " # debug_show(lhs) # ", rhs " # debug_show(rhs));
        let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
        // Debug.print("lhsSubaccount " # debug_show(lhsSubaccount));
        let rhsSubaccount : Subaccount = Option.get<Subaccount>(rhs.subaccount, _getDefaultSubaccount());
        // Debug.print("rhsSubaccount " # debug_show(rhsSubaccount));
        Principal.equal(lhs.owner, rhs.owner) and Blob.equal(lhsSubaccount, rhsSubaccount);
    };

    public func accountsHash(lhs : Account) : Nat32 {
         let lhsSubaccount : Subaccount = Option.get<Subaccount>(lhs.subaccount, _getDefaultSubaccount());
        let hashSum = Nat.add(Nat32.toNat(Principal.hash(lhs.owner)), Nat32.toNat(Blob.hash(lhsSubaccount)));
        Nat32.fromNat(hashSum % (2**32 - 1));
    };

    public func accountBelongToPrincipal(account : Account, principal : Principal) : Bool {
        Principal.equal(account.owner, principal);
    };
};
