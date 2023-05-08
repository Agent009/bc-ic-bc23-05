import List "mo:base/List";
import Book "./book";
import Utils "./utils";

actor {
    public type Book = Book.Book;
    public type List<T> = ?(T, List<T>);
    stable var book : Book = {
        title = "Test";
        pages = 0;
        read = false;
    };
    stable var books : List<Book> = null;

    // Create a book and read it before sending it back.
    // dfx canister call bc23_backend create_and_read_book '("book1", 5)''
    // Should return: (record { title = "book1"; read = true; pages = 10 : nat })
    public func create_and_read_book(title: Text, pages: Nat) : async Book {
        Book.create_book(title, pages);
    };

    // Add the new book to our list.
    // dfx canister call bc23_backend add_book '(record {title="book1"; pages=10; read=false})'
    // Should return: ()
    public func add_book(book: Book) : async () {
        books := Utils.prependToList<Book>(books, book);
    };

    // Return an Array of books (not List).
    // dfx canister call bc23_backend get_books
    // Should return: (vec { record { title = "book1"; read = false; pages = 10 : nat } })
    // After adding a second one (newest item prepended to the list):
    /*
    (
        vec {
            record { title = "book2"; read = false; pages = 15 : nat };
            record { title = "book1"; read = false; pages = 10 : nat };
        },
    )
    */
    public query func get_books() : async [Book] {
        List.toArray<Book>(books);   
    };
};
