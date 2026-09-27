<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

// Only Store Staff and Administrators may add books
$user = Auth::requireRole(['staff', 'admin']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('title', 'Title')
    ->required('author', 'Author')
    ->required('price', 'Price')->numeric('price')->min('price', 0, 'Price')
    ->required('stock', 'Stock')->numeric('stock')->min('stock', 0, 'Stock');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$db = Database::getConnection();
$stmt = $db->prepare('INSERT INTO books (title, author, description, price, stock, category, image_url, created_by)
    VALUES (:title, :author, :description, :price, :stock, :category, :image_url, :created_by)');

$stmt->execute([
    'title' => trim($input['title']),
    'author' => trim($input['author']),
    'description' => $input['description'] ?? '',
    'price' => (float)$input['price'],
    'stock' => (int)$input['stock'],
    'category' => $input['category'] ?? 'General',
    'image_url' => $input['image_url'] ?? null,
    'created_by' => $user['sub'],
]);

Response::success(['id' => (int)$db->lastInsertId()], 'Book created successfully', 201);
