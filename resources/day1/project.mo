import Int "mo:base/Int";
import Option "mo:base/Option";
import Calculator "Calculator";

actor bc2305 {
    //=============== DAY 1 - THE CALCULATOR ===============\\
    // https://github.com/motoko-bootcamp/motoko-starter/tree/main/days/day-1/project
    var counter : Float = 0;
    
    public func add(x : Float) : async Float {
        counter := Calculator.add(counter, x); 
        return counter;
    };
    
    public func sub(x : Float) : async Float {
        counter := Calculator.subtract(counter, x); 
        return counter;
    };
    
    public func mul(x : Float) : async Float {
        counter := Calculator.multiply(counter, x);  
        return counter;
    };
    
    public func div(x : Float) : async ?Float {
        counter := Option.get(Calculator.divide(counter, x), counter); 
        return Option.make(counter);
    };
    
    // dfx canister call bc2305 reset
    // Should set the counter to: 0
    public func reset(): async () {
        counter := 0;
    };
    
    // dfx canister call bc2305 see
    // Should give: (5 : nat)
    public query func see() : async Float {
        return counter;
    };
    
    public func power(x : Float) : async Float {
        counter := Calculator.power(counter, x); 
        return counter;
    };
    
    public func sqrt() : async Float {
        counter := Calculator.sqrt(counter); 
        return counter;
    };
    
    public func floor() : async Int {
        return Calculator.floor(counter);
    };
};
