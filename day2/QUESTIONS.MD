### [↩ Back to main README.md](../README.md)

# Motoko Bootcamp 2023 - Day 2 Question Answers

### 1. Who controls the ledger canister?

* The [nns/ledger](https://icscan.io/canister/ryjl3-tyaaa-aaaaa-aaaba-cai) is controlled by the [nns/root canister](https://icscan.io/canister/r7inp-6aaaa-aaaaa-aaabq-cai) (`r7inp-6aaaa-aaaaa-aaabq-cai`)

`dfx canister --network ic info ryjl3-tyaaa-aaaaa-aaaba-cai`
    
### 2. What is the subnet of the canister with the id: `mwrha-maaaa-aaaab-qabqq-cai`? How much nodes are running this subnet?

* This is the [Motoko Playground canister](https://icscan.io/canister/mwrha-maaaa-aaaab-qabqq-cai).
* It's subnet is [pae4o-o6dxf-xki7q-ezclx-znyd6-fnk6w-vkv5z-5lfwh-xym2i-otrrw-fqe](https://icscan.io/subnet/pae4o-o6dxf-xki7q-ezclx-znyd6-fnk6w-vkv5z-5lfwh-xym2i-otrrw-fqe).
* * **16 nodes** are running this subnet.

### 3. I have a neuron with 1O ICPs locked with a dissolve delay of 4 years - my neuron has been locked for 2 years. What is my expected voting power?

* **10 ICP** = **10 Principal Voting Power**
* A **dissolve delay / lock duration** of **4 years** gives a **voting power bonus** of **1.4986666666666668**.
* An **age** of **2 years** gives a **voting power bonus** of **1.125**.
* Therefore, the **expected voting power** is `10 * 1.4986666666666668 * 1.125`, which equals **16.86**.
* [Voting Power Documentation](https://internetcomputer.org/docs/current/tokenomics/nns/nns-staking-voting-rewards/#voting-power)

### 4. What is wrong with the following code?

* Missing the `Nat` import.
* Fix by adding `import Nat "mo:base/Nat";` at the top of the file.
* The function should also use the `query` keyword to return results faster, as it's not changing canister state.

### 5. What is wrong with the following code?

* The intention is not clear from the code. The `language` parameter in the `show_languages` method is redundant as it's not used.
* If the intention is to just return the list of languages, then the following errors need to be fixed:
* * Change `["English", "German"...` to `[var "English", "German"...` (add the `var` keyword before the first element)
* * Change return type from `async [var Text]` to `async [Text]`
* * Change the return from `return (languages)` to `return Array.freeze<Text>(languages)`. This will allow a snapshot of the array to be returned in an [immutable form](https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/base/Array#function-freeze).
* * The `language` parameter can also be removed as it's not used, and finally we can add the `query` keyword to speed up the returned response as we're not updating state.
* * The full correct version is provided below:

```
import Array "mo:base/Array";
actor {
    var languages : [var Text] = [var "English", "German", "Chinese", "Japanese", "French"];

    // dfx canister call bc23_backend show_languages
    // Gives output: (vec { "English"; "German"; "Chinese"; "Japanese"; "French" })
    public query func show_languages() : async [Text] {
        return Array.freeze<Text>(languages);
    };

};
```


### 6. What is wrong with the following code?

* Missing import, which needs to be added to the top of the file: `import Array "mo:base/Array";`. Adding this import fixes the issue at a basic level, but we can make other improvements as well.
* * The `append` function is deprecated, so we should utilise a different approach.
* * **Approach 1:** The `languages` array can be made mutable so that its elements can be modified. Then, we can use `Array.freeze` when returning the new array result.
* * **Approach 2:** Make use of `Array.thaw` to make the array mutable within the `add_language` function, add the new element to it, and then use `Array.freeze` when returning the new array result. 
* * **Approach 3 - PREFERRED:** Make use of `Buffer`. The full correct version is provided below:

```
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
actor {
    var languages : [Text] = ["English", "German", "Chinese", "Japanese", "French"];

    // dfx canister call bc23_backend add_language '("Urdu")'
    // Should give: (vec { "English"; "German"; "Chinese"; "Japanese"; "French"; "Urdu" })
    public func add_language(new_language : Text) : async [Text] {
        let buffer = Buffer.fromArray<Text>(languages);
        buffer.add(new_language);
        return Buffer.toArray(buffer);
    };

};
```
