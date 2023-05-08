import Int "mo:base/Int";
import Option "mo:base/Option";
import Diary "resources/day2/Diary";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";

actor bc2305 {
    //=============== DAY 2 - THE HOMEWORK DIARY ===============\\
    public type Homework = Diary.Homework;
    var homeworkDiary = Buffer.Buffer<Homework>(0);

    // Add a new homework task
    public func addHomework(homework : Homework) : async Nat {
        homeworkDiary.add(homework);
        return homeworkDiary.size() - 1;
    };

    // Get a specific homework task by id
    public query func getHomework(id : Nat) : async Result.Result<Homework, Text> {
        let result : ?Homework = homeworkDiary.getOpt(id);

        switch (result) {
            case (null) { #err("Invalid index.") };
            case (?record) { #ok(record) };
        };
    };

    // Update a homework task's title, description, and/or due date
    public func updateHomework(id : Nat, homework : Homework) : async Result.Result<(), Text> {
        let result : ?Homework = homeworkDiary.getOpt(id);

        switch (result) {
            case (null) { #err("Invalid index.") };
            case (?record) {
                var newRecord : Homework = {
                    title = switch (Text.size(homework.title)) { case (0) { record.title }; case (_) { homework.title }; };
                    description = switch (Text.size(homework.description)) { case (0) { record.description }; case (_) { homework.description }; };
                    dueDate = switch (record.dueDate > 0) { case (true) { homework.dueDate }; case (_) { record.dueDate }; };
                    completed = homework.completed;
                };

                homeworkDiary.put(id, newRecord);
                #ok() 
            };
        };
    };

    // Mark a homework task as completed
    public func markAsCompleted(id : Nat) : async Result.Result<(), Text> {
        let result : ?Homework = homeworkDiary.getOpt(id);

        switch (result) {
            case (null) { #err("Invalid index.") };
            case (?record) {
                var newRecord : Homework = {
                    title = record.title;
                    description = record.description;
                    dueDate = record.dueDate;
                    completed = true;
                };

                homeworkDiary.put(id, newRecord);
                #ok() 
            };
        };
    };

    // Delete a homework task by id
    public func deleteHomework(id : Nat) : async Result.Result<(), Text> {
        let result : ?Homework = homeworkDiary.getOpt(id);

        switch (result) {
            case (null) { #err("Invalid index.") };
            case (?record) {
                let x = homeworkDiary.remove(id);
                #ok() 
            };
        };
    };

    // Get the list of all homework tasks
    public query func getAllHomework() : async [Homework] {
        return Buffer.toArray<Homework>(homeworkDiary);
    };

    // Get the list of pending (not completed) homework tasks
    public query func getPendingHomework() : async [Homework] {
        let filteredEntries = Buffer.clone(homeworkDiary);
        filteredEntries.filterEntries(func(_, x) = x.completed == false);
        return Buffer.toArray<Homework>(filteredEntries);
    };

    // Search for homework tasks based on a search terms
    public query func searchHomework(searchTerm : Text) : async [Homework] {
        let filteredEntries = Buffer.clone(homeworkDiary);
        filteredEntries.filterEntries(func(_, x) {
            (Text.contains(x.title, #text searchTerm)) or (Text.contains(x.description, #text searchTerm));
        });
        return Buffer.toArray<Homework>(filteredEntries);
    };
};
