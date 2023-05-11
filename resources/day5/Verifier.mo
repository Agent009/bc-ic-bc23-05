import Result "mo:base/Result";
import Calculator "Calculator";

module Verifier {
    public type StudentProfile = {
        name : Text;
        team : Text;
        graduate : Bool;
    };
    public type TestError = {
        #UnexpectedValue : Text;
        #UnexpectedError : Text;
    };
    public type TestResult = Result.Result<(), TestError>;
    public type CalculatorOperation = {
        #add : Int;
        #sub : Nat;
        #reset;
        #nonExistent;
    };
    let bcICNetworkCanister = actor ("rww3b-zqaaa-aaaam-abioa-cai") : actor {
        add : shared (n : Int) -> async Int;
        sub : shared (n : Nat) -> async Int;
        reset : shared () -> async Int;
    };
};
