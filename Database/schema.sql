CREATE DATABASE book_management;
USE book_management;

-- =========================================
-- TABLE: users
-- =========================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL
);

-- =========================================
-- TABLE: publishers
-- =========================================

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- =========================================
-- TABLE: authors
-- =========================================

CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- TABLE: categories
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);
-- TABLE: books
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    published_year INT,
    publisher_id INT,

    FOREIGN KEY (publisher_id)
        REFERENCES publishers(publisher_id)
        ON DELETE SET NULL
);
-- TABLE: book_authors
-- MANY-TO-MANY
CREATE TABLE book_authors (
    book_id INT,
    author_id INT,

    PRIMARY KEY (book_id, author_id),

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,

    FOREIGN KEY (author_id)
        REFERENCES authors(author_id)
        ON DELETE CASCADE
);

-- TABLE: book_categories
-- MANY-TO-MANY

CREATE TABLE book_categories (
    book_id INT,
    category_id INT,

    PRIMARY KEY (book_id, category_id),

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE,

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id)
        ON DELETE CASCADE
);


-- TABLE: user_books
-- MANY-TO-MANY + ATTRIBUTES

CREATE TABLE user_books (
    user_book_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    book_id INT NOT NULL,

    status ENUM(
        'reading',
        'completed',
        'plan_to_read',
        'dropped'
    ) DEFAULT 'plan_to_read',

    rating INT CHECK (rating BETWEEN 1 AND 5),

    note TEXT,

    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, book_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE
);