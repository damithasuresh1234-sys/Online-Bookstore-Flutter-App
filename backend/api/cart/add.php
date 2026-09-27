<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

// Only customers add to their own cart
$user = Auth::requireRole(['customer']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('book_id', 'Book')->numeric('book_id')
    ->required('quantity', 'Quantity')->numeric('quantity')->min('quantity', 1, 'Quantity');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$bookId = (int)$input['book_id'];
$quantity = (int)$input['quantity'];

$db = Database::getConnection();

$bookStmt = $db->prepare('SELECT stock FROM books WHERE id = :id');
$bookStmt->execute(['id' => $bookId]);
$book = $bookStmt->fetch();

if (!$book) {
    Response::error('Book not found.', 404);
}

if ($quantity > (int)$book['stock']) {
    Response::error('Requested quantity exceeds available stock (' . $book['stock'] . ' left).', 422);
}

// If the book is already in the cart, increase quantity instead of duplicating
$stmt = $db->prepare('INSERT INTO cart_items (user_id, book_id, quantity)
    VALUES (:user_id, :book_id, :quantity)
    ON DUPLICATE KEY UPDATE quantity = quantity + :quantity2');

$stmt->execute([
    'user_id' => $user['sub'],
    'book_id' => $bookId,
    'quantity' => $quantity,
    'quantity2' => $quantity,
]);

Response::success(null, 'Book added to cart', 201);
