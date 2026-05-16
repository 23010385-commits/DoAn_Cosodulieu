INSERT INTO users(username, password_hash)
VALUES
('admin', '123456'),
('dung', 'abcdef');

-- PUBLISHERS
INSERT INTO publishers(name)
VALUES
('NXB Kim Dong'),
('Bloomsbury');

-- AUTHORS
INSERT INTO authors(name)
VALUES
('J.K Rowling'),
('Nguyen Nhat Anh');

-- CATEGORIES
INSERT INTO categories(name)
VALUES
('Fantasy'),
('Novel'),
('Adventure');

-- BOOKS
INSERT INTO books(title, published_year, publisher_id)
VALUES
('Harry Potter', 1997, 2),
('Cho Toi Xin Mot Ve Di Tuoi Tho', 2008, 1);

-- BOOK AUTHORS
INSERT INTO book_authors(book_id, author_id)
VALUES
(1, 1),
(2, 2);

-- BOOK CATEGORIES
INSERT INTO book_categories(book_id, category_id)
VALUES
(1, 1),
(1, 3),
(2, 2);

-- USER BOOKS
INSERT INTO user_books(user_id, book_id, status, rating, note)
VALUES
(1, 1, 'reading', 5, 'Very good book'),
(2, 2, 'completed', 4, 'Interesting');


SELECT 
    b.book_id,
    b.title,
    a.name AS author,
    p.name AS publisher
FROM books b
JOIN book_authors ba ON b.book_id = ba.book_id
JOIN authors a ON ba.author_id = a.author_id
LEFT JOIN publishers p ON b.publisher_id = p.publisher_id;