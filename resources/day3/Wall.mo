import Bool "mo:base/Bool";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
module Wall {
    public type Content = {
        #Text : Text;
        #Image : Blob;
        #Video : Blob;
    };
    public type Message = {
        vote: Int;
        content: Content;
        creator: Principal;
    };

    public func create_message(content : Content, creator: Principal) : Message {
        var message : Message = {
            vote = 0;
            content = content;
            creator = creator;
        };

        return message;
    };

    public func update_message_content(message: Message, content : Content) : Message {
        let updatedMessage : Message = {
            vote = message.vote;
            content = content;
            creator = message.creator;
        };

        return updatedMessage;
    };

    public func upvote_message(message: Message) : Message {
        let updatedMessage : Message = {
            vote = message.vote + 1;
            content = message.content;
            creator = message.creator;
        };

        return updatedMessage;
    };

    public func downvote_message(message: Message) : Message {
        var newVote : Int = message.vote - 1;

        if (newVote < 0) {
            newVote := 0;
        };

        let updatedMessage : Message = {
            vote = newVote;
            content = message.content;
            creator = message.creator;
        };

        return updatedMessage;
    };

    public func add_message_to_wall(wall: HashMap.HashMap<Nat, Message>, message: Message, previousId: Nat) : Nat {
        let nextId : Nat = previousId + 1;
        wall.put(nextId, message);
        return nextId;
    };
};
