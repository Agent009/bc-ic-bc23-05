actor {
    // Coding challenge 1: Write a function multiply that takes two natural numbers and returns the product.
    // dfx canister call bc23_day_1_backend multiply '(2, 3)'
    // Should give: (6 : nat)
    public query func multiply(n : Nat, m : Nat) : async Nat {
        return n * m;
    };

    // Coding challenge 2: Write a function volume that takes a natural number n and returns the volumte of a cube with side length n.
    // dfx canister call bc23_day_1_backend volume '(4)'
    // Should give: (64 : nat)
    public query func volume(n : Nat) : async Nat {
        return n * n * n;
    };

    // Coding challenge 3: Write a function hours_to_minutes that takes a number of hours n and returns the number of minutes.
    // dfx canister call bc23_day_1_backend hours_to_minutes '(10)'
    // Should give: (600 : nat)
    public query func hours_to_minutes(n : Nat) : async Nat {
        return n * 60;
    };

    // Coding challenge 4: Write two functions set_counter & get_counter.
    // set_counter sets the value of counter to n.
    // get_counter returns the current value of counter.
    var counter : Nat = 0;

    // dfx canister call bc23_day_1_backend set_counter '(5)'
    // Should set the counter to: 5
    public func set_counter(n : Nat) : async () {
        counter := n;
    };

    // dfx canister call bc23_day_1_backend get_counter
    // Should give: (5 : nat)
    public query func get_counter() : async Nat {
        return counter;
    };

    // Coding challenge 5: Write a function test_divide that takes two natural numbers n and m and returns a boolean indicating if n divides m.
    // dfx canister call bc23_day_1_backend test_divide '(2, 10)'
    // Should give: true
    // dfx canister call bc23_day_1_backend test_divide '(3, 10)'
    // Should give: false
    public query func test_divide(n: Nat, m : Nat) : async Bool {
        return m % n == 0;
    };

    // Coding challenge 6: Write a function is_even that takes a natural number n and returns a boolean indicating if n is even.
    // dfx canister call bc23_day_1_backend is_even '(12)'
    // Should give: true
    // dfx canister call bc23_day_1_backend is_even '(17)'
    // Should give: false
    public query func is_even(n : Nat) : async Bool  {
        return n % 2 == 0;
    };
};

