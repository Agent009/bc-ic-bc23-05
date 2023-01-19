### [↩ Back to main README.md](../README.md)

# Motoko Bootcamp 2023 - Day 3 Question Answers

### 1. True or False: the Internet Computer has a unique public key that can be used to verify responses coming from any subnets.

* **True**
* Each **subnet** has its own **static public key**.
* * Each **node** in the **subnet** has their own share of the **subnet**'s **public key**.
* All **subnets** orchestrated by the special **NNS** subnet, which has its own **public key**, and certifies all subnet keys.
* So, essentially, despite thousands of nodes and subnets, all that's really needed is the **single public key** of the **NNS**.

#### Resources Used

- [Inside the Internet Computer | Chain Key Cryptography](https://www.youtube.com/watch?v=vUcDRFC09J0) - describes the **Chain-Key Technology** and how it all revolves around a single public key (around 5 minute mark).

* [Chain-Key Cryptography](https://internetcomputer.org/how-it-works/chain-key-technology/)
* [Chain Key Cryptography: The Scientific Breakthrough Behind the Internet Computer](https://medium.com/dfinity/chain-key-technology-one-public-key-for-the-internet-computer-6a3644901e28)
* [DFINITY Service Worker](https://www.npmjs.com/package/@dfinity/service-worker)

`dfx canister --network ic info ryjl3-tyaaa-aaaaa-aaaba-cai`
    
### 2. True or False: when I realize an update call, the boundary node will participate in the consensus but not during query calls.

* **True**
* Query calls do not go through consensus

### 3. True or False: I can create a certified variable that will certify the response of the following actor:

* **True**
* Certified variables can be set during an update call to a canister, when the canister changes its state during a transaction that went through consensus.
* The certificate can then be read in a subsequent query call, so the canister can respond to a client's request in a trustworthy way but without incurring the additional delay of consensus.

#### Resources Used

* [How Internet Computer Responses Are Certified as Authentic
](https://medium.com/dfinity/how-internet-computer-responses-are-certified-as-authentic-2ff1bb1ea659) - certified variables are discussed half way down the page.
* [Certified Variables](https://internetcomputer.org/how-it-works/response-certification/)
* [Certified Assets from Motoko (PoC/Tutorial)](https://forum.dfinity.org/t/certified-assets-from-motoko-poc-tutorial/7263)
* [A motoko canister that does HTTP asset certification
](https://github.com/nomeata/motoko-certified-http)