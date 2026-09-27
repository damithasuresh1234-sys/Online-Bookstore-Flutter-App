<?php
/**
 * Database connection (PDO / MySQL)
 * Edit these values to match your local XAMPP MySQL setup.
 */
class Database
{
    private static $host = '127.0.0.1';
    private static $dbName = 'bookstore_db';
    private static $username = 'root';
    private static $password = ''; // default XAMPP root password is empty
    private static $connection = null;

    public static function getConnection(): PDO
    {
        if (self::$connection === null) {
            try {
                $dsn = 'mysql:host=' . self::$host . ';dbname=' . self::$dbName . ';charset=utf8mb4';
                self::$connection = new PDO($dsn, self::$username, self::$password, [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                ]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['success' => false, 'message' => 'Database connection failed: ' . $e->getMessage()]);
                exit;
            }
        }
        return self::$connection;
    }
}
