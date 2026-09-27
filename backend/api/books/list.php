<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$db = Database::getConnection();

$search = isset($_GET['search']) ? trim($_GET['search']) : '';
$category = isset($_GET['category']) ? trim($_GET['category']) : '';

$sql = 'SELECT id, title, author, description, price, stock, category, image_url, created_at FROM books WHERE 1=1';
$params = [];

if ($search !== '') {
    $sql .= ' AND (title LIKE :search OR author LIKE :search2)';
    $params['search'] = "%$search%";
    $params['search2'] = "%$search%";
}

if ($category !== '' && $category !== 'All') {
    $sql .= ' AND category = :category';
    $params['category'] = $category;
}

$sql .= ' ORDER BY created_at DESC';

$stmt = $db->prepare($sql);
$stmt->execute($params);
$books = $stmt->fetchAll();

// Cast numeric fields properly for JSON
foreach ($books as &$book) {
    $book['id'] = (int)$book['id'];
    $book['price'] = (float)$book['price'];
    $book['stock'] = (int)$book['stock'];
}

Response::success($books, 'Books retrieved successfully');
