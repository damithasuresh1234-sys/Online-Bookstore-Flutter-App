-- =========================================================
-- Online Bookstore - Database Schema
-- Import this into phpMyAdmin (XAMPP) or run via MySQL CLI
-- =========================================================

CREATE DATABASE IF NOT EXISTS bookstore_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE bookstore_db;

-- ---------------------------------------------------------
-- Users table: supports 3 roles -> customer, staff, admin
-- ---------------------------------------------------------
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(150) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('customer', 'staff', 'admin') NOT NULL DEFAULT 'customer',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Books table
-- ---------------------------------------------------------
CREATE TABLE books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(200) NOT NULL,
  author VARCHAR(150) NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  stock INT NOT NULL DEFAULT 0,
  category VARCHAR(80) DEFAULT 'General',
  image_url VARCHAR(500) DEFAULT NULL,
  created_by INT DEFAULT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_books_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Cart items (each customer has one active cart made of rows here)
-- ---------------------------------------------------------
CREATE TABLE cart_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  quantity INT NOT NULL DEFAULT 1,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cart_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_cart_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  UNIQUE KEY uniq_user_book (user_id, book_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Orders
-- ---------------------------------------------------------
CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  shipping_address VARCHAR(300) DEFAULT NULL,
  status ENUM('pending','processing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Order items (snapshot of book price at time of order)
-- ---------------------------------------------------------
CREATE TABLE order_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  book_id INT NOT NULL,
  title_snapshot VARCHAR(200) NOT NULL,
  price_snapshot DECIMAL(10,2) NOT NULL,
  quantity INT NOT NULL,
  CONSTRAINT fk_orderitems_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_orderitems_book FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------
-- Seed data
-- Default password for all seeded users is: Password123
-- (hash generated with PHP password_hash, BCRYPT)
-- ---------------------------------------------------------
INSERT INTO users (name, email, password_hash, role) VALUES
('System Admin', 'admin@bookstore.com', '$2y$10$eImiTXuWVxfM37uY4JANjQ==placeholder_replace_on_first_run', 'admin'),
('Store Staff', 'staff@bookstore.com', '$2y$10$eImiTXuWVxfM37uY4JANjQ==placeholder_replace_on_first_run', 'staff'),
('Jane Customer', 'customer@bookstore.com', '$2y$10$eImiTXuWVxfM37uY4JANjQ==placeholder_replace_on_first_run', 'customer');

INSERT INTO books (title, author, description, price, stock, category, image_url, created_by) VALUES
('Clean Code', 'Robert C. Martin', 'A handbook of agile software craftsmanship.', 32.50, 15, 'Technology', 'https://covers.openlibrary.org/b/isbn/0132350882-L.jpg', 1),
('The Pragmatic Programmer', 'Andrew Hunt', 'From journeyman to master, practical programming tips.', 29.99, 10, 'Technology', 'https://covers.openlibrary.org/b/isbn/020161622X-L.jpg', 1),
('1984', 'George Orwell', 'A dystopian social science fiction novel.', 12.99, 25, 'Fiction', 'https://covers.openlibrary.org/b/isbn/0451524934-L.jpg', 1),
('To Kill a Mockingbird', 'Harper Lee', 'A novel about racial injustice in the Deep South.', 14.50, 20, 'Fiction', 'https://covers.openlibrary.org/b/isbn/0060935464-L.jpg', 1),
('Sapiens', 'Yuval Noah Harari', 'A brief history of humankind.', 18.75, 12, 'Non-Fiction', 'https://covers.openlibrary.org/b/isbn/0062316095-L.jpg', 1),
('Atomic Habits', 'James Clear', 'An easy and proven way to build good habits.', 16.99, 30, 'Self-Help', 'https://covers.openlibrary.org/b/isbn/0735211299-L.jpg', 1);

-- NOTE: Run backend/database/generate_password_hashes.php once (see below)
-- and update the password_hash values above, OR simply register new
-- users through the app's /auth/register.php endpoint.
