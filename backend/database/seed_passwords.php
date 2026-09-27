<?php
/**
 * Run this ONCE from a browser after importing schema.sql, e.g.:
 *   http://localhost/bookstore_api/database/seed_passwords.php
 *
 * It replaces the placeholder password hashes for the 3 demo accounts
 * with a real bcrypt hash for the password: Password123
 *
 * Demo logins after running this:
 *   admin@bookstore.com    / Password123  (Administrator)
 *   staff@bookstore.com    / Password123  (Store Staff)
 *   customer@bookstore.com / Password123  (Customer)
 */

require_once __DIR__ . '/../config/database.php';

$password = 'Password123';
$hash = password_hash($password, PASSWORD_BCRYPT);

$db = Database::getConnection();
$stmt = $db->prepare("UPDATE users SET password_hash = :hash WHERE email IN
    ('admin@bookstore.com', 'staff@bookstore.com', 'customer@bookstore.com')");
$stmt->execute(['hash' => $hash]);

echo "Demo account passwords set successfully. You can now log in with:\n";
echo "admin@bookstore.com / staff@bookstore.com / customer@bookstore.com\n";
echo "Password: Password123\n";
