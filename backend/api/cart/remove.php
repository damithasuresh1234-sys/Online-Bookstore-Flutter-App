<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'DELETE'], true)) {
    Response::error('Method not allowed', 405);
}

$user = Auth::requireRole(['customer']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];
$cartItemId = isset($input['cart_item_id']) ? (int)$input['cart_item_id'] : (isset($_GET['cart_item_id']) ? (int)$_GET['cart_item_id'] : 0);

if ($cartItemId <= 0) {
    Response::error('A valid cart_item_id is required.', 422);
}

$db = Database::getConnection();
$stmt = $db->prepare('DELETE FROM cart_items WHERE id = :id AND user_id = :user_id');
$stmt->execute(['id' => $cartItemId, 'user_id' => $user['sub']]);

if ($stmt->rowCount() === 0) {
    Response::error('Cart item not found.', 404);
}

Response::success(null, 'Item removed from cart');
