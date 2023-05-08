import Bool "mo:base/Bool";
module Book {
    public type Book = {
        title : Text;
        pages : Nat;
        read: Bool;
    };

    // This function will create a new book based on the parameters passed and then read it before returning it.
    public func create_book(title: Text, pages: Nat) : Book {
        // Create the book.
        var book : Book = {
            title = title;
            pages = pages;
            read = false;
        };
        // Read the book.
        book := read_book(book);

        // And return-bory the now-very-well-read book.
        return book;
    };

    // Read the book, even if it's not Harry Potter or Lord of the Rings...
    let read_book = func (book: Book) : Book {
        {
            title = book.title;
            pages = book.pages;
            read = true;
        };
    };
};
