<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
if ($id <= 0) {
    Response::error('A valid book id is required.', 422);
}

$db = Database::getConnection();
$stmt = $db->prepare('SELECT * FROM books WHERE id = :id');
$stmt->execute(['id' => $id]);
$book = $stmt->fetch();

if (!$book) {
    Response::error('Book not found.', 404);
}

$book['id'] = (int)$book['id'];
$book['price'] = (float)$book['price'];
$book['stock'] = (int)$book['stock'];

Response::success($book, 'Book retrieved successfully');
