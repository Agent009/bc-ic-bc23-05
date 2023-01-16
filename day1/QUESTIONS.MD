### [↩ Back to main README.md](../README.md)

# Motoko Bootcamp 2023 - Day 1 Question Answers

### 1. How much is the current memory capacity of a canister?

* **4GB** stable memory according to [official documentation](https://internetcomputer.org/docs/current/references/ic-interface-spec#system-api-stable-memory).
* There is an [executed proposal (18337)](https://dashboard.internetcomputer.org/proposal/18337) to increase the limit to **300GB**.
    
### 2. What is the issue with the following code sample?

* The `counter` variable is declared with the `let` keyword, which makes it **immutable**, so it's value cannot be changed inside the `increment_counter` function.

### 3. What is the issue with the following code sample?

* The `message` variable is declared as type `Text`, but is then assigned an `Nat` / `Int` value, so this won't compile. Changing the `0` to a string such as `""` will fix the issue.
* The `change_message` function is declared as a `query` function, so it won't update the `message`. Removing the `query` keyword from the function declaration will fix the issue.

### 4. False or True: we can remove the keyword async for return argument of a query function since queries are faster to answer.

* **False**
