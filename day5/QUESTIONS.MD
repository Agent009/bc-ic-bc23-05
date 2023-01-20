### [↩ Back to main README.md](../README.md)

# Motoko Bootcamp 2023 - Day 5 Question Answers

### 1. True or False: we can prevent the heap being erased during upgrades by using a stable heap.

* **True**
* The Internet Computer’s persistence model allows a canister to save and restore **stable heap** data (**stable storage**) to dedicated stable memory that, unlike ordinary canister memory, is retained across an upgrade, allowing a canister to transfer data in bulk to its replacement canister ([ref](https://internetcomputer.org/docs/current/developer-docs/build/cdks/motoko-dfinity/upgrades))).

### 2. A.call() -> B.call() -> C How much time (or rounds of consensus) do we need to wait for an answer?

* There are multiple factors to consider, including are they `query` (faster, no consensus required) or `update` (slower, consensus required) calls, and whether the canisters are in the same or different subnets.
* Assuming that canisters A, B and C are in the same subnet and we're performing an `update` call, then we will need 2 rounds of consensus (~4 seconds) ([ref](https://forum.dfinity.org/t/inter-canister-query-calls-community-consideration/6754)).
    * 2 seconds (A → B) + 2 seconds (B → C) = 4 seconds for A to get a response
    * An inter-canister call to canisters in the same subnet takes 1 round of consensus (~2 seconds).


### 3. Is possible to realize an intercanister call in query mode?

* **Yes** ([ref 1](https://forum.dfinity.org/t/inter-canister-query-calls-community-consideration/6754), [ref 2](https://internetcomputer.org/docs/current/references/security/rust-canister-development-security-best-practices#inter-canister-calls-and-rollbacks))