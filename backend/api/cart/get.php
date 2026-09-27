<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

$user = Auth::requireAuth();

$db = Database::getConnection();
$stmt = $db->prepare('SELECT ci.id AS cart_item_id, ci.quantity, b.id AS book_id, b.title, b.author,
        b.price, b.image_url, b.stock
    FROM cart_items ci
    JOIN books b ON b.id = ci.book_id
    WHERE ci.user_id = :user_id
    ORDER BY ci.created_at DESC');
$stmt->execute(['user_id' => $user['sub']]);
$items = $stmt->fetchAll();

$total = 0;
foreach ($items as &$item) {
    $item['cart_item_id'] = (int)$item['cart_item_id'];
    $item['quantity'] = (int)$item['quantity'];
    $item['book_id'] = (int)$item['book_id'];
    $item['price'] = (float)$item['price'];
    $item['stock'] = (int)$item['stock'];
    $item['subtotal'] = round($item['price'] * $item['quantity'], 2);
    $total += $item['subtotal'];
}

Response::success(['items' => $items, 'total' => round($total, 2)], 'Cart retrieved successfully');
