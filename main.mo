import Int "mo:base/Int";
import Cycles "mo:base/ExperimentalCycles";
import Option "mo:base/Option";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import TrieMap "mo:base/TrieMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import Float "mo:base/Float";
import Random "mo:base/Random";
import Log "resources/day6/Log";
import Types "resources/day6/Types";

import Coin "resources/day4/Coin";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "resources/day4/BootcampLocalActor";

// Actor class with the capability to accept init bootstrap data.
// The init has been made optional, so that we can deploy without bootstrapping as well.
shared ({ caller = creator }) actor class bc2305(init : ?Types.InitPayload) = Self {
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:    PARAMETERS   ----------   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //=============== DAY 6 - THE MOTOKO COIN - UPGRADED ===============\\
    // https://github.com/motoko-bootcamp/motoko-starter/tree/main/days/day-6/project
    type Account = Coin.Account;
    // dfx identity get-principal
    let owner : Account = Coin.getAccountFromPrincipal(Principal.fromText("jxic7-kzwkr-4kcyk-2yql7-uqsrg-lvrzb-k7avx-e4nbh-nfmli-rddvs-mqe"));
    // Max supply = 1B
    let maxSupply : Nat = 1_000_000_000;
    let ownerInitialSupply : Nat = 1_000_000;
    let airdropAmount : Nat = 100;
    let tokenDesc : Text = "MotoCoin";
    let tokenSymbol : Text = "MOC";
    var logMessage : Text = "";
    let bcICNetworkCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
        getAllStudentsPrincipal : shared () -> async [Principal]
    };
    // Stable stores
    stable var ledgerEntries : [(Account, Nat)] = [];
    stable var airdropEntries : [(Text, [Account])] = [];
    stable var logsEntries : [(Time.Time, Text)] = [];
    stable var system_params : Types.SystemParams = switch (init) {
        case null { Types.defaulSystemParams };
        case (?i) { {} }
    };
    // In-memory stores that we can utilise during canister operation. These will be saved to stable memory during upgrades.
    let ledger = TrieMap.fromEntries<Account, Nat>(ledgerEntries.vals(), Coin.accountsEqual, Coin.accountsHash);
    let airdrops = TrieMap.fromEntries<Text, [Account]>(airdropEntries.vals(), Text.equal, Text.hash);
    let logs = HashMap.fromIter<Time.Time, Text>(logsEntries.vals(), Iter.size(logsEntries.vals()), Int.equal, Int.hash);

    // Give the owner the initial allocated supply. This duplicate call is needed so that the first time the canister is deployed
    // the owner is properly given the initial allocated supply. This is because on first deployment, the system preupgrade / postupgrade
    // methods do not get called, so the code within there will have no effect.
    if (ledger.size() < 1) {
        ledger.put(owner, ownerInitialSupply)
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      TOKEN       RELATED     ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // Returns the name of the token
    public query func getTokenName() : async Text {
        return tokenDesc
    };

    // Returns the symbol of the token
    public query func getTokenSymbol() : async Text {
        return tokenSymbol
    };

    // Returns the the total number of tokens - i.e. the max supply.
    public query func getTokenTotalSupply() : async Nat {
        return maxSupply
    };

    // Returns the the total number of tokens on all accounts.
    public query func getTokenClaimedSupply() : async Nat {
        var claimed : Nat = Coin.totalClaimedSupply(ledger);

        logAndDebug("Total claimed supply " # debug_show (claimed));
        return claimed
    };

    // Returns the the total number of remaining tokens that can be claimed.
    public query func getTokenRemainingSupply() : async Nat {
        let claimed : Nat = Coin.totalClaimedSupply(ledger);
        let remaining : Nat = maxSupply - claimed;

        logAndDebug("Remaining supply " # debug_show (remaining));
        return remaining
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      LEDGER      RELATED     ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    public query func getAccountFromPrincipal(principal : Principal) : async Account {
        return Coin.getAccountFromPrincipal(principal)
    };

    public func addPrincipalToLedger(principal : Principal) : async () {
        let account : Account = Coin.getAccountFromPrincipal(principal);

        switch (ledger.get(account)) {
            // Only add the account to ledger if it doesn't already exist.
            case (null) { ledger.put(account, 0) };
            case (_) {}
        }
    };

    public query func getLedgerAccounts() : async [Principal] {
        let newMap = TrieMap.map<Account, Nat, Principal>(ledger, Coin.accountsEqual, Coin.accountsHash, func(key, value) = key.owner);
        logAndDebug("Getting accounts. Total = " # debug_show (newMap.size()));
        return Iter.toArray<Principal>(newMap.vals())
    };

    public query func getLedgerBalanceFor(account : Account) : async (Nat) {
        return getLedgerBalanceForAccount(account)
    };

    public shared ({ caller }) func getMyLedgerBalance() : async (Nat) {
        return getLedgerBalanceForAccount(Coin.getAccountFromPrincipal(caller))
    };

    private func getLedgerBalanceForAccount(account : Account) : (Nat) {
        let balance : Nat = switch (ledger.get(account)) {
            case (null) { 0 };
            case (?amount) { amount }
        };

        logAndDebug(debug_show (("balance of", account, "is", balance)));
        return balance
    };

    // Transfer tokens to another account
    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
        var senderBalance : Nat = getLedgerBalanceForAccount(from);
        var receiverBalance : Nat = getLedgerBalanceForAccount(to);
        logAndDebug(debug_show (("transferring", amount, "from", from, "who has a current balance of", senderBalance)));

        if (senderBalance >= amount) {
            // Do the transfer
            let newFromBalance : Nat = senderBalance - amount;
            ledger.put(from, newFromBalance);
            let toBalance : Nat = getLedgerBalanceForAccount(to);
            let newToBalance : Nat = toBalance + amount;
            ledger.put(to, newToBalance);
            logAndDebug(debug_show (("transferred", amount, "to", to, "who had a balance of", toBalance, "and now has a balance of", newToBalance)));
            return #ok()
        } else {
            logAndDebug(debug_show (("cannot transfer", amount, "to", to, "because", from, "has insufficient balance", senderBalance)));
            return #err("Insufficient balance. Cannot transfer " # Nat.toText(amount) # " as only " # Nat.toText(senderBalance) # " is available.")
        }
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:     AIRDROP      RELATED     ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // Airdrop {airdropAmount} tokens to any student that is part of the Bootcamp.
    // dfx canister --network ic call rww3b-zqaaa-aaaam-abioa-cai getAllStudentsPrincipal '()'
    public func airdrop(id : Text, max : Nat) : async Result.Result<(), Text> {
        let principals : [Principal] = shuffle(await getAllAccounts());
        var count : Nat = 0;

        label principalsLoop for (principal in principals.vals()) {
            try {
                // logAndDebug("Starting airdrop for " # debug_show(principal));
                let account : Account = Coin.getAccountFromPrincipal(principal);
                // logAndDebug("Fetched account " # debug_show(account));

                // Only airdrop if the account hasn't received an airdrop of this type before.
                let airdropAccounts : [Account] = getAirdropAccounts(id);
                var receivedAirdrop : Bool = false;

                for (airdropAccount in airdropAccounts.vals()) {
                    if (Coin.accountsEqual(account, airdropAccount)) {
                        receivedAirdrop := true
                    }
                };

                if (receivedAirdrop == false) {
                    // Flag up this account as having received an airdrop.
                    Debug.print("airdrop - airdropAccounts array size: " # debug_show (airdropAccounts.size()));
                    Debug.print(debug_show (airdropAccounts));
                    let buffer = Buffer.fromArray<Account>(airdropAccounts);
                    buffer.add(account);
                    airdrops.put(id, Buffer.toArray<Account>(buffer));

                    // Update balance after airdrop
                    let existingBalance : Nat = getLedgerBalanceForAccount(account);
                    ledger.put(account, existingBalance + airdropAmount);
                    count += 1;
                    logAndDebug(debug_show ("Airdropped", airdropAmount, "to", account, "for the", id, "airdrop."));

                    if (max > 0 and count >= max) {
                        break principalsLoop
                    }
                } else {
                    logAndDebug(debug_show ("Cannot airdrop", airdropAmount, "to", account, "because the account has already received an", id, "airdrop."))
                }
            } catch (e) {
                logAndDebug("An error occured when perforing the airdrop for principal: " # Principal.toText(principal));
                return #err("An error occured when perforing the airdrop.")
            }
        };

        return #ok()
    };

    public query func doesAccountHaveAirdrop(id : Text, account : Account) : async Bool {
        let airdropAccounts : [Account] = getAirdropAccounts(id);
        var receivedAirdrop : Bool = false;

        for (airdropAccount in airdropAccounts.vals()) {
            if (Coin.accountsEqual(account, airdropAccount)) {
                receivedAirdrop := true
            }
        };

        if (receivedAirdrop == true) {
            logAndDebug(debug_show (("Account", account, "has received the", id, "airdrop.")))
        };

        return receivedAirdrop
    };

    public shared ({ caller }) func getMyAirdrops() : async [Text] {
        var airdropIDs = Buffer.Buffer<Text>(0);

        for ((airdropID, airdropAccounts) in airdrops.entries()) {
            for (airdropAccount in airdropAccounts.vals()) {
                if (Coin.accountsEqual(Coin.getAccountFromPrincipal(caller), airdropAccount)) {
                    airdropIDs.add(airdropID)
                }
            }
        };

        let airdropIDsArray = Buffer.toArray<Text>(airdropIDs);

        if (airdropIDs.size() > 0) {
            logAndDebug(debug_show ("Caller", caller, "has received the following airdrops: ", airdropIDsArray))
        };

        return airdropIDsArray
    };

    private func getAirdropAccounts(id : Text) : [Account] {
        let airdropAccounts : [Account] = switch (airdrops.get(id)) {
            case (null) { [] };
            case (?result) { result }
        };

        logAndDebug(debug_show (("Total accounts that have received the", id, "airdrop:", airdropAccounts.size())));
        return airdropAccounts;
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:       MISC      ----------   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // dfx canister call bc2305 getAllAccounts '()'
    private func getAllAccounts() : async [Principal] {
        // TODO: Change this to "true" for local testing.
        let isLocal : Bool = true;

        if (isLocal) {
            let bootcampTestActor = await BootcampLocalActor.BootcampLocalActor();
            let principals : [Principal] = await bootcampTestActor.getAllStudentsPrincipal();

            for (principal in principals.vals()) {
                // Debug.print("Creating ledger entry for principal: " # debug_show(principal));
                let account : Account = Coin.getAccountFromPrincipal(principal);
                // Debug.print("Account: " # debug_show(account));
                ledger.put(account, 0)
            };

            // Debug.print("getAllAccounts() - ledger entries done");
            return principals
        } else {
            // For the IC network.
            let principals : [Principal] = await bcICNetworkCanister.getAllStudentsPrincipal();

            for (principal in principals.vals()) {
                ledger.put(Coin.getAccountFromPrincipal(principal), 0)
            };

            return principals
        }
    };

    private func shuffle<T>(elements : [T]) : [T] {
        var currentIndex = elements.size();
        let seed : Blob = "\14\C9\72\09\03\D4\D5\72\82\95\E5\43\AF\FA\A9\44\49\2F\25\56\13\F3\6E\C7\B0\87\DC\76\08\69\14\CF";
        let random = Random.rangeFrom(32, seed);
        // between 0..4294967295
        let max : Float = 4294967295;
        let newRandom = Float.fromInt(random) / max;
        let shuffled : [var T] = Array.thaw<T>(elements);

        while (0 != currentIndex) {
            var randomIndex = Int.abs(Float.toInt(Float.floor(newRandom * Float.fromInt(currentIndex))));
            currentIndex -= 1;
            var tempValue = elements[currentIndex];
            shuffled[currentIndex] := shuffled[randomIndex];
            shuffled[randomIndex] := tempValue;
            // D.print(debug_show (randomIndex));
            // D.print(debug_show (currentIndex));
            // D.print(debug_show (tempValue.id))
        };

        return Array.freeze<T>(shuffled);
    };

    public query func seeAllLogMessages() : async [(Time.Time, Text)] {
        logAndDebug("Displaying all log messages.");
        return Iter.toArray<(Time.Time, Text)>(logs.entries())
    };

    public func clearLogMessages() : async () {
        logAndDebug("Clearing all log messages.");

        for (key in logs.keys()) {
            logs.delete(key)
        };

        logsEntries := []
    };

    private func logAndDebug(message : Text) {
        Log.logAndOrDebug(logs, message, true)
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      SYSTEM     MANAGEMENT   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/heartbeats
    // Called on every Internet Computer subnet heartbeat, by scheduling an asynchronous call to the heartbeat function.
    // Due to its async return type, a heartbeat function may send further messages and await results.
    // The result of a heartbeat call, including any trap or thrown error, is ignored.
    // The implicit context switch inherent to calling every Motoko async function, means that the time the heartbeat body is executed may be later than the time the heartbeat was issued by the subnet.
    // There are issues around hearbeat cycle burn rate (https://forum.dfinity.org/t/cycle-burn-rate-heartbeat/12090), so we won't be enabling this.
    /*system func heartbeat() : async () {
        let timestamp = Time.now();
        // Debug.print("heartbeat - timestamp: " # debug_show(timestamp));
        // await execute_accepted_proposals()
    };*/

    // Get the current system params
    public query func get_system_params() : async Types.SystemParams {
        system_params
    };

    func getMyPrincipal() : Principal {
        return Principal.fromActor(Self)
    };

    // Update system params
    public shared ({ caller }) func update_system_params(payload : Types.UpdateSystemParamsPayload) : async () {
        // Only callable via proposal execution by this actor itself
        if (caller != getMyPrincipal()) {
            return
        };

        system_params := {}
    };

    // Get the cycles balance
    public query func cycle_balance() : async Nat {
        let balance = Cycles.balance();
        Debug.print("Cycles balance: " # debug_show (balance));
        return balance
    };

    // Receive cycles
    public shared ({ caller }) func receive_cycles() : async Result.Result<Text, Text> {
        let cycles = Cycles.available();
        Debug.print("Received and accepted cycles: " # debug_show (cycles));
        ignore Cycles.accept(cycles);
        return #ok("Thanks. Accepted " # debug_show (cycles) # " cycles.")
    };

    public shared ({ caller }) func send_cycles(principalID : Text) : async Result.Result<Text, Text> {
        Debug.print("Current balance: " # Nat.toText(Cycles.balance()));
        let recipient : actor {
            receive_cycles : () -> async Result.Result<Text, Text>
        } = actor (principalID);
        Cycles.add(1_000_000_100);
        let send = await recipient.receive_cycles();
        Debug.print("Unused balance: " # Nat.toText(Cycles.refunded()));
        send
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      UPGARDE    MANAGEMENT   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // Make a final update to stable variables, before the runtime commits their values to Internet Computer stable memory, and performs an upgrade.
    // So, here we want to take our values that are in our HashMap (and not stable) and put them into the stable array instead.
    // Ref: https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/upgrades#preupgrade-and-postupgrade-system-methods
    system func preupgrade() {
        ledgerEntries := Iter.toArray(ledger.entries());
        airdropEntries := Iter.toArray(airdrops.entries());
        logsEntries := Iter.toArray(logs.entries())
    };

    // Runs after an upgrade has initialized the replacement actor, including its stable variables, but before executing any shared function call (or message) on that actor.
    // Here, we want to reset the stable var, as we'll be storing the data to be used in our HashMap.
    system func postupgrade() {
        ledgerEntries := [];
        airdropEntries := [];
        logsEntries := [];

        // Give the owner the initial allocated supply. This ensures the owner is only supplied with the initial once,
        // and not on each deployment of the canister.
        if (ledger.size() < 1) {
            ledger.put(owner, ownerInitialSupply)
        }
    };
}
