CREATE DATABASE book_management;
USE book_management;

-- =====================================================
-- USERS
-- =====================================================

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,

    username VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL UNIQUE,

    password_hash VARCHAR(255) NOT NULL,

    role ENUM('user', 'admin')
        DEFAULT 'user',

    status ENUM('active', 'blocked')
        DEFAULT 'active',

    created_at TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- PUBLISHERS
-- =====================================================

CREATE TABLE publishers (
    publisher_id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(255) NOT NULL
);

-- =====================================================
-- AUTHORS
-- =====================================================

CREATE TABLE authors (
    author_id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(255) NOT NULL
);

-- =====================================================
-- CATEGORIES
-- =====================================================

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,

    name VARCHAR(100) NOT NULL UNIQUE
);

-- =====================================================
-- BOOKS
-- =====================================================

CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,

    title VARCHAR(255) NOT NULL,

    description TEXT,

    published_year INT,

    cover_image VARCHAR(255),

    publisher_id INT,

    FOREIGN KEY (publisher_id)
        REFERENCES publishers(publisher_id)
        ON DELETE SET NULL
);

-- =====================================================
-- BOOK_AUTHORS
-- MANY TO MANY
-- =====================================================

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

-- =====================================================
-- BOOK_CATEGORIES
-- MANY TO MANY
-- =====================================================

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

-- =====================================================
-- USER_BOOKS
-- TỦ SÁCH CÁ NHÂN
-- =====================================================

CREATE TABLE user_books (
    user_book_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    book_id INT NOT NULL,

    status ENUM(
        'reading',
        'completed',
        'plan_to_read',
        'favorite',
        'dropped'
    ) DEFAULT 'plan_to_read',

    rating INT
        CHECK (rating BETWEEN 1 AND 5),

    note TEXT,

    added_at TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(user_id, book_id),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE
);

-- =====================================================
-- READING HISTORY
-- =====================================================

CREATE TABLE reading_history (
    history_id INT AUTO_INCREMENT PRIMARY KEY,

    user_id INT NOT NULL,
    book_id INT NOT NULL,

    read_time INT DEFAULT 0,

    last_read_at TIMESTAMP
        DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
        ON DELETE CASCADE,

    FOREIGN KEY (book_id)
        REFERENCES books(book_id)
        ON DELETE CASCADE
);
