import Bool "mo:base/Bool";
import Time "mo:base/Time";

module Diary {
    public type Time = Time.Time;
    public type Homework = {
        title : Text;
        description : Text;
        dueDate : Time;
        completed : Bool;
    };
};
