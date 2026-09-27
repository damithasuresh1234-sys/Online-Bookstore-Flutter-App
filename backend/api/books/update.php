<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT'], true)) {
    Response::error('Method not allowed', 405);
}

Auth::requireRole(['staff', 'admin']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('id', 'Book id')
    ->required('title', 'Title')
    ->required('author', 'Author')
    ->required('price', 'Price')->numeric('price')->min('price', 0, 'Price')
    ->required('stock', 'Stock')->numeric('stock')->min('stock', 0, 'Stock');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$db = Database::getConnection();

$check = $db->prepare('SELECT id FROM books WHERE id = :id');
$check->execute(['id' => (int)$input['id']]);
if (!$check->fetch()) {
    Response::error('Book not found.', 404);
}

$stmt = $db->prepare('UPDATE books SET title = :title, author = :author, description = :description,
    price = :price, stock = :stock, category = :category, image_url = :image_url WHERE id = :id');

$stmt->execute([
    'id' => (int)$input['id'],
    'title' => trim($input['title']),
    'author' => trim($input['author']),
    'description' => $input['description'] ?? '',
    'price' => (float)$input['price'],
    'stock' => (int)$input['stock'],
    'category' => $input['category'] ?? 'General',
    'image_url' => $input['image_url'] ?? null,
]);

Response::success(null, 'Book updated successfully');
