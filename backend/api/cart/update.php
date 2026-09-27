<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT'], true)) {
    Response::error('Method not allowed', 405);
}

$user = Auth::requireRole(['customer']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('cart_item_id', 'Cart item')->numeric('cart_item_id')
    ->required('quantity', 'Quantity')->numeric('quantity')->min('quantity', 1, 'Quantity');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$db = Database::getConnection();

// Ensure the cart item belongs to this user (ownership check)
$stmt = $db->prepare('SELECT ci.id, b.stock FROM cart_items ci JOIN books b ON b.id = ci.book_id
    WHERE ci.id = :id AND ci.user_id = :user_id');
$stmt->execute(['id' => (int)$input['cart_item_id'], 'user_id' => $user['sub']]);
$row = $stmt->fetch();

if (!$row) {
    Response::error('Cart item not found.', 404);
}

if ((int)$input['quantity'] > (int)$row['stock']) {
    Response::error('Requested quantity exceeds available stock (' . $row['stock'] . ' left).', 422);
}

$update = $db->prepare('UPDATE cart_items SET quantity = :quantity WHERE id = :id');
$update->execute(['quantity' => (int)$input['quantity'], 'id' => (int)$input['cart_item_id']]);

Response::success(null, 'Cart updated successfully');
