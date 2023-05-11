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
import Debug "mo:base/Debug";

import IC "IC";
import Calculator "Calculator";
import Verifier "Verifier";
import Error "mo:base/Error";
import Time "mo:base/Time";

actor bc2305 {
    //=============== DAY 5 - THE VERIFIER ===============\\
    // https://github.com/motoko-bootcamp/motoko-starter/tree/main/days/day-5/project
    type CanisterId = IC.CanisterId;
    type CanisterSettings = IC.CanisterSettings;
    type ManagementCanister = IC.ManagementCanister;
    type CanisterStatus = IC.CanisterStatus;
    type StudentProfile = Verifier.StudentProfile;
    type TestError = Verifier.TestError;
    type TestResult = Verifier.TestResult;
    type CalculatorOperation = Verifier.CalculatorOperation;
    let managementCanisterId : Text = "aaaaa-aa";
    stable var studentProfileStoreEntries : [(Principal, StudentProfile)] = [];
    stable var verifyStoreEntries : [(Principal, Principal)] = [];
    stable var logStoreEntries : [(Time.Time, Text)] = [];
    // Create an in-memory array of neurons so we can work with them easier during canister operation. These will be saved to stable memory during upgrades.
    let studentProfileStore = HashMap.fromIter<Principal, StudentProfile>(studentProfileStoreEntries.vals(), Iter.size(studentProfileStoreEntries.vals()), Principal.equal, Principal.hash);
    let verifyStore = HashMap.fromIter<Principal, Principal>(verifyStoreEntries.vals(), Iter.size(verifyStoreEntries.vals()), Principal.equal, Principal.hash);
    let logStore = HashMap.fromIter<Time.Time, Text>(logStoreEntries.vals(), Iter.size(logStoreEntries.vals()), Int.equal, Int.hash);
    var logMessage : Text = "";

    // Part 1 - Profile Management
    public shared ({ caller }) func addMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        Debug.print("Adding profile for " # debug_show (caller));
        studentProfileStore.put(caller, profile);
        return #ok();
    };
    public shared ({ caller }) func updateMyProfile(profile : StudentProfile) : async Result.Result<(), Text> {
        Debug.print("Updating profile for " # debug_show (caller));
        return await updateProfile(profile, caller);
    };
    public func updateProfile(profile : StudentProfile, principalId : Principal) : async Result.Result<(), Text> {
        Debug.print("Updating profile for " # debug_show (principalId));
        let result : ?StudentProfile = studentProfileStore.get(principalId);

        switch (result) {
            case (null) {
                return #err("No student profile found for principal " # debug_show (principalId) # ".");
            };
            case (?record) {
                let newRecord : StudentProfile = {
                    name = switch (Text.size(profile.name)) {
                        case (0) { record.name };
                        case (_) { profile.name };
                    };
                    team = switch (Text.size(profile.team)) {
                        case (0) { record.team };
                        case (_) { profile.team };
                    };
                    graduate = profile.graduate;
                };

                studentProfileStore.put(principalId, newRecord);
                return #ok();
            };
        };
    };
    public shared ({ caller }) func deleteMyProfile() : async Result.Result<(), Text> {
        Debug.print("Deleting profile for " # debug_show (caller));
        let result : ?StudentProfile = studentProfileStore.get(caller);

        switch (result) {
            case (null) {
                return #err("You do not have a student profile that you can delete.");
            };
            case (?record) {
                studentProfileStore.delete(caller);
                return #ok();
            };
        };
    };
    public func seeAProfile(p : Principal) : async Result.Result<StudentProfile, Text> {
        Debug.print("Checking profile for " # debug_show (p));
        let result : ?StudentProfile = studentProfileStore.get(p);

        switch (result) {
            case (null) {
                return #err("No student profile record found for the supplied principal.");
            };
            case (?record) { return #ok(record) };
        };
    };
    public query func seeAllProfiles() : async [StudentProfile] {
        Debug.print("Displaying all profiles.");
        return Iter.toArray<StudentProfile>(studentProfileStore.vals());
    };
    public query func seeAllVerificationRequests() : async [(Principal, Principal)] {
        Debug.print("Displaying all verification requests.");
        return Iter.toArray<(Principal, Principal)>(verifyStore.entries());
    };
    public func clearVerificationRequests() : async () {
        Debug.print("Clearing all verification requests.");
        
        for (key in verifyStore.keys()) {
            verifyStore.delete(key);
        };

        verifyStoreEntries := [];
    };
    public query func seeAllLogMessages() : async [(Time.Time, Text)] {
        Debug.print("Displaying all log messages.");
        return Iter.toArray<(Time.Time, Text)>(logStore.entries());
    };
    public func clearLogMessages() : async () {
        Debug.print("Clearing all log messages.");
        
        for (key in logStore.keys()) {
            logStore.delete(key);
        };

        logStoreEntries := [];
    };

    //Part 2 - Calculator Test
    public shared ({ caller }) func test(p : Principal) : async TestResult {
        logMessage := "Testing for " # debug_show (p);
        Debug.print(logMessage);
        logStore.put(Time.now(), logMessage);
        // TODO: Change this to "true" for local testing.
        let isLocal : Bool = Principal.isAnonymous(p);
        var testActor = actor (Principal.toText(p)) : actor {
            add : shared (n : Int) -> async Int;
            sub : shared (n : Nat) -> async Int;
            reset : shared () -> async Int;
        };

        if (isLocal) {
            testActor := await Calculator.Calculator();
            logStore.put(Time.now(), "Using local actor");
        };

        var opResult : Result.Result<Int, Text> = await performCalculatorOperation(testActor, #reset);
        var expectedVal : Int = 0;

        switch (opResult) {
            // Capture unexpected errors
            case (#err(err)) {
                return #err(#UnexpectedError(err));
            };
            // Capture incorrect value errors
            case (#ok(n)) {
                if (n != expectedVal) {
                    return #err(#UnexpectedValue("n should be " # debug_show (expectedVal) # ", but is instead " # debug_show (n)));
                };
            };
        };

        opResult := await performCalculatorOperation(testActor, #add(10));
        expectedVal := 10;

        switch (opResult) {
            // Capture unexpected errors
            case (#err(err)) {
                return #err(#UnexpectedError(err));
            };
            // Capture incorrect value errors
            case (#ok(n)) {
                if (n != expectedVal) {
                    return #err(#UnexpectedValue("n should be " # debug_show (expectedVal) # ", but is instead " # debug_show (n)));
                };
            };
        };

        opResult := await performCalculatorOperation(testActor, #sub(5));
        expectedVal := 5;

        switch (opResult) {
            // Capture unexpected errors
            case (#err(err)) {
                return #err(#UnexpectedError(err));
            };
            // Capture incorrect value errors
            case (#ok(n)) {
                if (n != expectedVal) {
                    return #err(#UnexpectedValue("n should be " # debug_show (expectedVal) # ", but is instead " # debug_show (n)));
                };
            };
        };

        /*opResult := await performCalculatorOperation(testActor, #nonExistent);
        expectedVal := 0;

        switch (opResult) {
            // Capture unexpected errors
            case (#err(err)) {
                return #err(#UnexpectedError(err));
            };
            // Capture incorrect value errors
            case (#ok(n)) {
                if (n != expectedVal) {
                    return #err(#UnexpectedValue("n should be " # debug_show(expectedVal) # ", but is instead " # debug_show(n)));
                };
            };
        };*/

        return #ok();
    };

    private func performCalculatorOperation(
        testActor : actor {
            add : shared (n : Int) -> async Int;
            sub : shared (n : Nat) -> async Int;
            reset : shared () -> async Int;
        },
        operation : CalculatorOperation,
    ) : async Result.Result<Int, Text> {
        try {
            switch (operation) {
                case (#add(n)) {
                    return #ok(await testActor.add(n));
                };
                case (#sub(n)) {
                    return #ok(await testActor.sub(n));
                };
                case (#reset) {
                    return #ok(await testActor.reset());
                };
                case (#nonExistent) {
                    return #err("Error executing operation " # debug_show (operation));
                };
            };
        } catch (e) {
            Debug.print("Error executing operation " # debug_show (operation) # ". Details: " # debug_show (Error.code(e)) # " " # debug_show (Error.message(e)));
            return #err("Error executing operation " # debug_show (operation));
        };
    };

    //Part 3 - Verifying the controller of the calculator
    // In this section we want to make sure that the owner of the verified canister is actually the student that registered it.
    // Otherwise, a student could use the canister of another one.
    public shared ({ caller }) func verifyOwnership(canisterId : CanisterId, principalId : Principal) : async Bool {
        logMessage := "Verifying ownership of canister " # debug_show (canisterId) # " for principal " # debug_show (principalId);
        Debug.print(logMessage);
        logStore.put(Time.now(), logMessage);
        verifyStore.put(canisterId, principalId);
        var managementCanistor = actor (managementCanisterId) : ManagementCanister;

        try {
            let canisterStatus : CanisterStatus = await managementCanistor.canister_status({
                canister_id : CanisterId = canisterId;
            });
            logStore.put(Time.now(), "Canister status: " # debug_show (canisterStatus));
            let controllers : [Principal] = canisterStatus.settings.controllers;
            logStore.put(Time.now(), "Controllers: " # debug_show (controllers));

            for (controller in controllers.vals()) {
                if (Principal.equal(principalId, controller)) {
                    logStore.put(Time.now(), "Controller matches principalId");
                    return true;
                };
            };

            logStore.put(Time.now(), "None of the controllers match the principalId");
            return false;
        } catch (e) {
            // Currently, the canister_status method of the management canister can only be used when the canister calling it is 
            // also one of the controller of the canister you are trying to check the status. 
            // Fortunately there is a trick to still get the controller!
            logMessage := "Error verifying ownership. Details: " # debug_show (Error.code(e)) # " " # debug_show (Error.message(e));
            Debug.print(logMessage);
            logStore.put(Time.now(), logMessage);
            let controllers : [Principal] = IC.parseControllersFromCanisterStatusErrorIfCallerNotController(Error.message(e));
            logStore.put(Time.now(), "Controllers: " # debug_show (controllers));

            for (controller in controllers.vals()) {
                if (Principal.equal(principalId, controller)) {
                    logStore.put(Time.now(), "Controller matches principalId");
                    return true;
                };
            };

            logStore.put(Time.now(), "None of the controllers match the principalId");
            return false;
        };

        return false;
    };

    //Part 4 - Graduation
    public shared ({ caller }) func verifyWork(canisterId : CanisterId, principalId : Principal) : async Result.Result<(), Text> {
        logMessage := "Verifying work of canister " # debug_show (canisterId) # " for principal " # debug_show (principalId);
        Debug.print(logMessage);
        logStore.put(Time.now(), logMessage);
        verifyStore.put(canisterId, principalId);

        // Verify that the principalId is a controller of the canisterId
        logMessage := "Verify that the principalId is a controller of the canisterId";
        Debug.print(logMessage);
        logStore.put(Time.now(), logMessage);
        let ownershipVerified : Bool = await verifyOwnership(canisterId, principalId);

        if (ownershipVerified != true) {
            return #err("Ownership verification failure.");
        };

        // Verify that the principalId is a controller of the canisterId
        let testPassed : TestResult = await test(canisterId);

        switch (testPassed) {
            case (#ok) {
                let result : Result.Result<StudentProfile, Text> = await seeAProfile(principalId);

                switch (result) {
                    case (#err(err)) {
                        return #err("No student profile found. Cannot update graduation status.");
                    };
                    case (#ok(sp)) {
                        let np : StudentProfile = {
                            name = sp.name;
                            team = sp.team;
                            graduate = true;
                        };
                        ignore await updateProfile(np, principalId);
                        return #ok();
                    };
                };
            };
            case (#err(#UnexpectedValue(err))) {
                return #err("Test failed - unexpected value: " # debug_show (err));
            };
            case (#err(#UnexpectedError(err))) {
                return #err("Test failed - unexpected error: " # debug_show (err));
            };
        };
    };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      UPGARDE    MANAGEMENT   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // Make a final update to stable variables, before the runtime commits their values to Internet Computer stable memory, and performs an upgrade.
    // So, here we want to take our values that are in our HashMap (and not stable) and put them into the stable array instead.
    // Ref: https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/upgrades#preupgrade-and-postupgrade-system-methods
    system func preupgrade() {
        studentProfileStoreEntries := Iter.toArray(studentProfileStore.entries());
        verifyStoreEntries := Iter.toArray(verifyStore.entries());
        logStoreEntries := Iter.toArray(logStore.entries());
    };

    // Runs after an upgrade has initialized the replacement actor, including its stable variables, but before executing any shared function call (or message) on that actor.
    // Here, we want to reset the stable var, as we'll be storing the data to be used in our HashMap.
    system func postupgrade() {
        studentProfileStoreEntries := [];
        verifyStoreEntries := [];
        logStoreEntries := [];
    };
};
