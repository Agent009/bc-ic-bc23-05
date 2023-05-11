import Int "mo:base/Int";
import Option "mo:base/Option";
import Wall "Wall";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Order "mo:base/Order";
import Array "mo:base/Array";

actor bc2305 {
    //=============== DAY 3 - THE STUDENT WALL ===============\\
    // https://github.com/motoko-bootcamp/motoko-starter/tree/main/days/day-3/project
    public type Content = Wall.Content;
    public type Message = Wall.Message;
    public type RankedMessage = {
        messageId : Nat;
        rank : Int;
    };
    var messageId : Nat = 0;
    var wall = HashMap.HashMap<Nat, Message>(1, Nat.equal, Hash.hash);

    // Add a new message to the wall
    public shared ({ caller }) func writeMessage(c : Content) : async Nat {
        // Create the message from the content.
        let message : Message = Wall.create_message(c, caller);
        // Add it to the wall and return the new message ID.
        messageId := Wall.add_message_to_wall(wall, message, messageId);
        return messageId;
    };

    //Get a specific message by ID
    public query func getMessage(messageId : Nat) : async Result.Result<Message, Text> {
        let message : ?Message = wall.get(messageId);

        switch (message) {
            case (null) { return #err("Invalid message ID supplied.") };
            case (?record) { return #ok(record) };
        };
    };

    // Update the content for a specific message by ID
    public shared ({ caller }) func updateMessage(messageId : Nat, c : Content) : async Result.Result<(), Text> {
        let message : ?Message = wall.get(messageId);

        switch (message) {
            case (null) { return #err("Invalid message ID supplied.") };
            case (?record) {
                if (Principal.notEqual(caller, record.creator)) {
                    return #err("Only the creator of the message can update it.");
                };

                wall.put(messageId, Wall.update_message_content(record, c));
                return #ok();
            };
        };
    };

    //Delete a specific message by ID
    public shared ({ caller }) func deleteMessage(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.remove(messageId);

        switch (message) {
            case (null) { return #err("Invalid message ID supplied.") };
            case (?record) { #ok() };
        };
    };

    // Voting
    public shared ({ caller }) func upVote(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.remove(messageId);

        switch (message) {
            case (null) { return #err("Invalid message ID supplied.") };
            case (?record) {
                let updatedMessage = Wall.upvote_message(record);
                wall.put(messageId, updatedMessage);
                #ok();
            };
        };
    };
    public shared ({ caller }) func downVote(messageId : Nat) : async Result.Result<(), Text> {
        let message : ?Message = wall.remove(messageId);

        switch (message) {
            case (null) { return #err("Invalid message ID supplied.") };
            case (?record) {
                let updatedMessage = Wall.downvote_message(record);
                wall.put(messageId, updatedMessage);
                #ok();
            };
        };
    };

    //Get all messages
    public query func getAllMessages() : async [Message] {
        return Iter.toArray<(Message)>(wall.vals());
    };

    //Get all messages
    public query func getAllMessagesRanked() : async [Message] {
        // Create a buffer to store the ranked messages.
        var rankedMessages = Buffer.Buffer<RankedMessage>(0);
        for ((key, value) in wall.entries()) {
            let rankedMessage : RankedMessage = {
                messageId = key;
                rank = value.vote;
            };
            rankedMessages.add(rankedMessage);
        };

        rankedMessages.sort(compareRankedMessages);
        Buffer.reverse(rankedMessages);
        var sortedMessages = Buffer.Buffer<Message>(0);

        for (rankedMessage in rankedMessages.vals()) {
            let message : ?Message = wall.get(rankedMessage.messageId);

            switch (message) {
                case (null) {  };
                case (?record) { sortedMessages.add(record); };
            };
        };

        return Buffer.toArray<Message>(sortedMessages);
    };

    private func compareRankedMessages(x : RankedMessage, y : RankedMessage) : Order.Order {
        if (x.rank < y.rank) { #less } else if (x.rank == y.rank) { #equal } else {
            #greater;
        };
    };
};
