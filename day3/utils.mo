import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Int "mo:base/Int";
import List "mo:base/List";
import Option "mo:base/Option";

module Utils {

    // Challenge 1: Takes an array [Int] of integers and returns the second largest number in the array.
    public func second_maximum(array : [Int]) : Int {
        if (array.size() < 1) {
            return 0;
        } else {
            if (array.size() == 1) {
                return array[0];
            } else {
                Array.sort<Int>(array, Int.compare)[array.size() - 2];
            };
        };
    };

    // Challenge 2: Takes an array [Nat] and returns a new array with only the odd numbers from the original array.
    public func remove_even(array : [Nat]) : [Nat] {
        let buffer = Buffer.Buffer<Nat>(3);

        for (num in array.vals()) {
            // We like the odd ones...
            if (num % 2 > 0) {
                buffer.add(num);
            };
        };

        return Buffer.toArray<Nat>(buffer);
    };

    // Challenge 3: Takes 2 parameters: an array [T] and a Nat n. This function will drop the n first elements of the array and returns the remainder.
    // Do not use a loop.
    public func drop<T>(xs : [T], n : Nat) : [T] {
        // So, we want to drop more elements than there are present... rightio! 
        if (n >= xs.size()) {
            return [];
        };

        // If we don't want to drop anything, then why did we even come here for?!
        if (n <= 0) {
            return xs;
        };

        let buffer = Buffer.fromArray<T>(xs);
        // n will always be more than 0 at this point, so will not trap despite the syntax warning below.
        buffer.filterEntries(func(i, x) = i > (n - 1));

        return Buffer.toArray<T>(buffer);
    };

    public query func dropFromText(xs : [Text], n : Nat) : async [Text] {
      return drop<Text>(xs, n);
    };

    public query func dropFromInt(xs : [Int], n : Nat) : async [Int] {
      return drop<Int>(xs, n);
    };

    // Add the new item to the beginning of the list.
    public func prependToList<T>(list : List.List<T>, newItem : T) : List.List<T> {
        List.push<T>(newItem, list);
    };
};
