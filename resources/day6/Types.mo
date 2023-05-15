import Result "mo:base/Result";
import Trie "mo:base/Trie";
import Int "mo:base/Int";
import Nat "mo:base/Nat";
import List "mo:base/List";
import Principal "mo:base/Principal";

module Types {
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:      GENERIC    ----------   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    
    public type Result<T, E> = Result.Result<T, E>;
    public type SystemParams = {};
    public let defaulSystemParams : SystemParams = {};
    public let oneToken = { amount_e8s = 100_000 };
    public let zeroToken = { amount_e8s = 0 };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:     ACCOUNTS    ----------   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    // User accounts with the tokens that they hold
    public type Tokens = { amount_e8s : Nat };

    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------
    //  REGION:    BOOTSTRAP    ----------   ----------   ----------   ----------   ----------   ----------
    //----------   ----------   ----------   ----------   ----------   ----------   ----------   ----------

    public type UpdateSystemParamsPayload = {};
    public type InitPayload = {};
}
