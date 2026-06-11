-- =====================================================
-- USERS
-- =====================================================

INSERT INTO users (
    username,
    email,
    password_hash,
    role,
    status
)
VALUES
(
    'admin',
    'admin@book.com',
    '123456',
    'admin',
    'active'
),
(
    'dung',
    'dung@gmail.com',
    'abcdef',
    'user',
    'active'
),
(
    'tan',
    'tan@gmail.com',
    'ghijkl',
    'user',
    'active'
);

-- =====================================================
-- PUBLISHERS
-- =====================================================

INSERT INTO publishers(name)
VALUES
('NXB Kim Dong'),
('Bloomsbury');

-- =====================================================
-- AUTHORS
-- =====================================================

INSERT INTO authors(name)
VALUES
('J.K. Rowling'),
('Nguyen Nhat Anh'),
('Dale Carnegie');

-- =====================================================
-- CATEGORIES
-- =====================================================

INSERT INTO categories(name)
VALUES
('Fantasy'),
('Novel'),
('Adventure'),
('Self Help'),
('Romance');

-- =====================================================
-- BOOKS
-- =====================================================

INSERT INTO books (
    title,
    description,
    published_year,
    cover_image,
    publisher_id
)
VALUES
(
    'Harry Potter',
    'A fantasy novel series about a young wizard.',
    1997,
    'harry_potter.jpg',
    2
),
(
    'Cho Toi Xin Mot Ve Di Tuoi Tho',
    'A famous Vietnamese novel about childhood memories.',
    2008,
    'tuoi_tho.jpg',
    1
),
(
    'Dac Nhan Tam',
    'Cuon sach ky nang song noi tieng cua Dale Carnegie.',
    1936,
    'dac_nhan_tam.jpg',
    1
),
(
    'Mat Biec',
    'Tieu thuyet noi tieng cua Nguyen Nhat Anh ve tinh yeu tuoi hoc tro.',
    1990,
    'mat_biec.jpg',
    1
);

-- =====================================================
-- BOOK AUTHORS
-- =====================================================

INSERT INTO book_authors(book_id, author_id)
VALUES
(1, 1), -- Harry Potter -> J.K. Rowling
(2, 2), -- Cho Toi Xin Mot Ve Di Tuoi Tho -> Nguyen Nhat Anh
(3, 3), -- Dac Nhan Tam -> Dale Carnegie
(4, 2); -- Mat Biec -> Nguyen Nhat Anh

-- =====================================================
-- BOOK CATEGORIES
-- =====================================================

INSERT INTO book_categories(book_id, category_id)
VALUES
(1, 1), -- Fantasy
(1, 3), -- Adventure

(2, 2), -- Novel

(3, 4), -- Self Help

(4, 2), -- Novel
(4, 5); -- Romance

-- =====================================================
-- USER BOOKS (PERSONAL BOOKSHELF)
-- =====================================================

INSERT INTO user_books(
    user_id,
    book_id,
    status,
    rating,
    note
)
VALUES
(
    1,
    1,
    'reading',
    5,
    'Very good book'
),
(
    2,
    2,
    'completed',
    4,
    'Interesting'
),
(
    2,
    3,
    'reading',
    5,
    'Motivational book'
),
(
    2,
    4,
    'plan_to_read',
    NULL,
    'Will read later'
);

-- =====================================================
-- READING HISTORY
-- =====================================================

INSERT INTO reading_history(
    user_id,
    book_id,
    read_time
)
VALUES
(1, 1, 120),
(1, 1, 45),
(2, 2, 90),
(2, 3, 60),
(2, 4, 30);

-- =====================================================
-- TEST QUERY
-- =====================================================

SELECT
    b.book_id,
    b.title,
    a.name AS author,
    p.name AS publisher,
    b.published_year
FROM books b
JOIN book_authors ba
    ON b.book_id = ba.book_id
JOIN authors a
    ON ba.author_id = a.author_id
LEFT JOIN publishers p
    ON b.publisher_id = p.publisher_id;