### [↩ Back to main README.md](../README.md)

# Motoko Bootcamp 2023 - Day 4 Question Answers

### 1. Is the heap memory saved when upgrading a canister? How much heap memory does a canister has?

* Only the data stored in `stable` variables in the **stable memory** is saved and persisted across upgrades. All other data is lost during an upgrade. 
* The **heap memory** is still limited to **4GB**, that's still limited by the **Wasm runtime** which supports **32-bit native memory** ([ref](https://forum.dfinity.org/t/increased-canister-smart-contract-memory/6148/144)).

### 2. How much accounts can a unique Principal own?

* **4,294,967,295** (maximum value of a **32-bit** unsigned integer)

### 3. Can we safely upgrade a canister from interface A to interface B?

* No, because the **candid interface** will change due to the extra parameter.
* Changes to a Motoko function may change the Candid interface, and that could potentially break the application.
