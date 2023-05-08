import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";
import Text "mo:base/Text";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import { equal } "mo:base/Nat";
import Debug "mo:base/Debug";

actor {
    // 1. Write a function average_array that takes an array of integers and returns the average value of the elements in the array.
    // dfx canister call bc23_backend average_array '(vec {2;3;4})'
    // Should give: (3 : int)
    // dfx canister call bc23_backend average_array '(vec {2;3})'
    // Should give: (2 : int) (rounded down)
    public query func average_array(array : [Int]) : async Int {
        var sum : Int = 0;
        var count : Int = array.size();

        for (val in array.vals()) {
            sum += val;
        };

        let average : Float = Float.fromInt(sum) / Float.fromInt(count);

        return Float.toInt(average);
    };

    // 2. Character count: Write a function that takes in a string and a character, and returns the number of occurrences of that character in the string.
    // dfx canister call bc23_backend count_character '("Characters", 97)'
    // Should give: (2 : nat) ('a')
    // dfx canister call bc23_backend count_character '("Characters", 122)'
    // Should give: (0 : nat) ('z')
    public query func count_character(t : Text, c : Char) : async Nat {
        var count : Nat = 0;

        for (char in t.chars()) {
            if (char == c) {
                count += 1;
            };
        };

        return count;
    };

    // 3. Write a function factorial that takes a natural number n and returns the factorial of n.
    // dfx canister call bc23_backend factorial '(0)'
    // Should give: (1 : nat)
    // dfx canister call bc23_backend factorial '(3)'
    // Should give: (6 : nat)
    public query func factorial(n : Nat) : async Nat {
        let result = func factorialize(num : Nat) : Nat {
            if (num < 0) {
                return (0 - 1);
            } else {
                if (num == 0) {
                    return 1;
                } else {
                    num * factorialize(num - 1);
                };
            };
        };

        return result(n);
    };

    // 4. Write a function number_of_words that takes a sentence and returns the number of words in the sentence.
    // dfx canister call bc23_backend number_of_words '("This sentence has 5 words.")'
    // Should give: (5 : nat)
    public query func number_of_words(t : Text) : async Nat {
        let iter : Iter.Iter<Text> = Text.split(t, #text(" "));

        return Iter.size<Text>(iter);
    };

    // 5. Write a function find_duplicates that takes an array of natural numbers and returns a new array containing all duplicate numbers.
    // The order of the elements in the returned array should be the same as the order of the first occurrence in the input array.
    // dfx canister call bc23_backend find_duplicates '(vec {10;5;5;15;20;10})'
    // Should give: (vec { 10 : nat; 5 : nat })
    public query func find_duplicates(a : [Nat]) : async [Nat] {
        var duplicates = Buffer.Buffer<Nat>(0);

        var sum = 0;
        for (i in a.keys()) {
            let num : Nat = a.get(i);
            var otherElements = Buffer.Buffer<Nat>(0);

            for (j in a.keys()) {
                if (j != i) {
                    otherElements.add(a.get(j));
                };
            };

            if (otherElements.size() > 0 and Buffer.contains<Nat>(otherElements, num, equal) and not Buffer.contains<Nat>(duplicates, num, equal)) {
                duplicates.add(num);
            };
        };

        return Buffer.toArray(duplicates);
    };

    // 6. Write a function convert_to_binary that takes a natural number n and returns a string representing the binary representation of n.
    // dfx canister call bc23_backend convert_to_binary '(6)'
    // Should give: (vec {0; 1; 1; 0})
    // dfx canister call bc23_backend convert_to_binary '(20)'
    // Should give: (vec {0; 1; 0; 1; 0; 0})
    public query func convert_to_binary(n : Nat) : async Text {
        // Our limit is 64 bits.
        let b = Array.init<Nat64>(64, 0x00);
        // Keep a record of the index as we loop through bytes.
        var id : Nat = 0;
        // We will need to work with the provided number, so let's grab a local Nat64 copy of it.
        var num : Nat64 = Nat64.fromIntWrap(n);

        // Let's create the necessary bit values.
        // The modulus allows us to work out if a bit needs to be set or not.
        // At each iteration, we divide the working copy of the number by 2, as the next bit (to the left) is double in value to the current one.
        while (num > 0) {
            b[id] := num % 2;
            num := num / 2;
            id += 1;
        };

        // We now need to reverse the bits, so we can display them properly (most significant to the left)
        // Debug.print(debug_show(b));
        let buffer = Buffer.Buffer<Nat64>(id);

        // Reverse the bits by looping through the bits in reverse order, and appending the elements onto a new buffer in the right order.
        while (id > 0) {
            buffer.add(b[id]);

            if (id == 1) {
                buffer.add(b[0]);
            };

            id -= 1;
        };

        // Finally, we need to convert the array of bits into a text string.
        // Debug.print(debug_show(Buffer.toArray(buffer)));
        var binaryString : Text = "";

        for (element in buffer.vals()) {
            binaryString := binaryString # Nat64.toText(element);
        };

        // return Array.freeze(b);
        // return Buffer.toArray(buffer);
        return binaryString;
    };
};
