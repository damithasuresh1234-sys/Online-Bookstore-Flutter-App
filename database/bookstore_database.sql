-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 13, 2026 at 06:30 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `bookstore_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE `books` (
  `id` int(11) NOT NULL,
  `title` varchar(200) NOT NULL,
  `author` varchar(150) NOT NULL,
  `description` text DEFAULT NULL,
  `price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `stock` int(11) NOT NULL DEFAULT 0,
  `category` varchar(80) DEFAULT 'General',
  `image_url` varchar(500) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `books`
--

INSERT INTO `books` (`id`, `title`, `author`, `description`, `price`, `stock`, `category`, `image_url`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Clean Code', 'Robert C. Martin', 'A handbook of agile software craftsmanship.', 32.50, 12, 'Technology', 'https://covers.openlibrary.org/b/isbn/0132350882-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-13 15:00:15'),
(2, 'The Pragmatic Programmer', 'Andrew Hunt', 'From journeyman to master, practical programming tips.', 29.99, 9, 'Technology', 'https://covers.openlibrary.org/b/isbn/020161622X-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-13 12:53:31'),
(3, '1984', 'George Orwell', 'A dystopian social science fiction novel.', 12.99, 25, 'Fiction', 'https://covers.openlibrary.org/b/isbn/0451524934-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-12 15:47:35'),
(4, 'To Kill a Mockingbird', 'Harper Lee', 'A novel about racial injustice in the Deep South.', 14.50, 20, 'Fiction', 'https://covers.openlibrary.org/b/isbn/0060935464-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-12 15:47:35'),
(5, 'Sapiens', 'Yuval Noah Harari', 'A brief history of humankind.', 18.75, 12, 'Non-Fiction', 'https://covers.openlibrary.org/b/isbn/0062316095-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-12 15:47:35'),
(6, 'Atomic Habits', 'James Clear', 'An easy and proven way to build good habits.', 16.99, 100, 'Self-Help', 'https://covers.openlibrary.org/b/isbn/0735211299-L.jpg', 1, '2026-09-12 15:47:35', '2026-09-13 15:10:25');

-- --------------------------------------------------------

--
-- Table structure for table `cart_items`
--

CREATE TABLE `cart_items` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_amount` decimal(10,2) NOT NULL DEFAULT 0.00,
  `shipping_address` varchar(300) DEFAULT NULL,
  `status` enum('pending','processing','shipped','completed','cancelled') NOT NULL DEFAULT 'pending',
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `total_amount`, `shipping_address`, `status`, `created_at`, `updated_at`) VALUES
(1, 3, 65.00, 'test address no560 srilanka', 'shipped', '2026-09-12 16:54:12', '2026-09-12 23:54:25'),
(2, 3, 29.99, 'Test Address no 007 Sri lanka', 'pending', '2026-09-13 12:53:31', '2026-09-13 12:53:31'),
(3, 4, 32.50, 'test Address no257 Sri Lanka', 'pending', '2026-09-13 15:00:14', '2026-09-13 15:00:14');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int(11) NOT NULL,
  `order_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `title_snapshot` varchar(200) NOT NULL,
  `price_snapshot` decimal(10,2) NOT NULL,
  `quantity` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `book_id`, `title_snapshot`, `price_snapshot`, `quantity`) VALUES
(1, 1, 1, 'Clean Code', 32.50, 2),
(2, 2, 2, 'The Pragmatic Programmer', 29.99, 1),
(3, 3, 1, 'Clean Code', 32.50, 1);

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` enum('customer','staff','admin') NOT NULL DEFAULT 'customer',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `role`, `is_active`, `created_at`) VALUES
(1, 'System Admin', 'admin@bookstore.com', '$2y$10$u6mj8PskHtVAIxHEcHTK1.sX/xU5L/8K7Fb2HKj5v13NuPBbUHurW', 'admin', 1, '2026-09-12 15:47:35'),
(2, 'Store Staff', 'staff@bookstore.com', '$2y$10$u6mj8PskHtVAIxHEcHTK1.sX/xU5L/8K7Fb2HKj5v13NuPBbUHurW', 'staff', 1, '2026-09-12 15:47:35'),
(3, 'Jane Customer', 'customer@bookstore.com', '$2y$10$u6mj8PskHtVAIxHEcHTK1.sX/xU5L/8K7Fb2HKj5v13NuPBbUHurW', 'customer', 1, '2026-09-12 15:47:35'),
(4, 'damitha', 'damitha123@gmail.com', '$2y$10$ZzmTrEuMqAMp/ErFAM8ja.vI5oy6eUCPq0ZV7O5kujq9WfawEzkZW', 'customer', 1, '2026-09-12 17:23:37'),
(5, 'Suresh', 'suresh123@gmail.com', '$2y$10$KTzqTGzVVHOsNFPpLYsHNeo/7kHOU9lsNrRTSWVFTmHzvyKXAaU.e', 'customer', 1, '2026-09-13 13:57:00');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_books_created_by` (`created_by`);

--
-- Indexes for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_user_book` (`user_id`,`book_id`),
  ADD KEY `fk_cart_book` (`book_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_orders_user` (`user_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_orderitems_order` (`order_id`),
  ADD KEY `fk_orderitems_book` (`book_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `books`
--
ALTER TABLE `books`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `cart_items`
--
ALTER TABLE `cart_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `books`
--
ALTER TABLE `books`
  ADD CONSTRAINT `fk_books_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `cart_items`
--
ALTER TABLE `cart_items`
  ADD CONSTRAINT `fk_cart_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_cart_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_orderitems_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_orderitems_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
