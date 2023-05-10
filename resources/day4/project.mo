import Int "mo:base/Int";
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

import Coin "Coin";
// NOTE: only use for local dev,
// when deploying to IC, import from "rww3b-zqaaa-aaaam-abioa-cai"
import BootcampLocalActor "BootcampLocalActor";
import Debug "mo:base/Debug";

actor bc2305 {
    //=============== DAY 4 - THE MOTOKO COIN ===============\\
    type Account = Coin.Account;
    var ledger = TrieMap.TrieMap<Account, Nat>(Coin.accountsEqual, Coin.accountsHash);
    let airdropAmount : Nat = 100;
    let bcICNetworkCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
        getAllStudentsPrincipal : shared () -> async [Principal];
    };

    // Returns the name of the token
    public query func name() : async Text {
        return "MotoCoin";
    };

    // Returns the symbol of the token
    public query func symbol() : async Text {
        return "MOC";
    };

    // Returns the the total number of tokens on all accounts
    public query func totalSupply() : async Nat {
        var total : Nat = 0;

        for ((account, balance) in ledger.entries()) {
            total += balance;
        };

        return total;
    };

    public query func getAccounts() : async [Principal] {
        let newMap = TrieMap.map<Account, Nat, Principal>(ledger, Coin.accountsEqual, Coin.accountsHash, func(key, value) = key.owner);
        return Iter.toArray<Principal>(newMap.vals());
    };

    public query func getAccountFromPrincipal(principal : Principal) : async Account {
        return Coin.getAccountFromPrincipal(principal);
    };

    public func addPrincipalToLedger(principal : Principal) : async () {
        let account : Account = Coin.getAccountFromPrincipal(principal);
        ledger.put(account, 0);
    };

    public query func balanceOf(account : Account) : async (Nat) {
        let balance : ?Nat = ledger.get(account);

        switch (balance) {
            case (null) { return 0 };
            case (?amount) { return amount };
        };
    };

    // Transfer tokens to another account
    public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
        var senderBalance : ?Nat = ledger.get(from);
        var receiverBalance : ?Nat = ledger.get(to);

        switch (senderBalance) {
            case (null) {
                return #err("The sender doesn't have any balance.");
            };
            case (?balance) {
                if (balance < amount) {
                    return #err("The sender doesn't have enough balance.");
                };

                ledger.put(from, balance - amount);

                switch (receiverBalance) {
                    case (null) { ledger.put(to, amount) };
                    case (?rBalance) { ledger.put(to, rBalance + amount) };
                };

                return #ok();
            };
        };
    };

    // Airdrop 1000 MotoCoin to any student that is part of the Bootcamp.
    // dfx canister --network ic call rww3b-zqaaa-aaaam-abioa-cai getAllStudentsPrincipal '()'
    public func airdrop() : async Result.Result<(), Text> {
        let principals : [Principal] = await getAllAccounts();

        for (principal in principals.vals()) {
            try {
                // Debug.print("Starting airdrop for " # debug_show(principal));
                let account : Account = Coin.getAccountFromPrincipal(principal);
                // Debug.print("Fetched account " # debug_show(account));
                ledger.put(account, airdropAmount);
                // Debug.print("Aidrop successful for " # debug_show(principal));
            } catch (e) {
                Debug.print("An error occured when perforing the airdrop for principal: " # Principal.toText(principal));
                return #err("An error occured when perforing the airdrop.");
            };
        };

        return #ok();
    };

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
                ledger.put(account, 0);
            };

            // Debug.print("getAllAccounts() - ledger entries done");
            return principals;
        } else {
            // For the IC network.
            let principals : [Principal] = await bcICNetworkCanister.getAllStudentsPrincipal();

            for (principal in principals.vals()) {
                ledger.put(Coin.getAccountFromPrincipal(principal), 0);
            };

            return principals;
        };
    };
};
