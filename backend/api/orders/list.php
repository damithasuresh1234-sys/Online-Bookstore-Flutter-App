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

// Customers only see their own orders. Staff and Admin see every order.
if ($user['role'] === 'customer') {
    $stmt = $db->prepare('SELECT o.*, u.name AS customer_name, u.email AS customer_email
        FROM orders o JOIN users u ON u.id = o.user_id
        WHERE o.user_id = :user_id ORDER BY o.created_at DESC');
    $stmt->execute(['user_id' => $user['sub']]);
} else {
    $stmt = $db->query('SELECT o.*, u.name AS customer_name, u.email AS customer_email
        FROM orders o JOIN users u ON u.id = o.user_id ORDER BY o.created_at DESC');
}

$orders = $stmt->fetchAll();

$itemsStmt = $db->prepare('SELECT book_id, title_snapshot, price_snapshot, quantity FROM order_items WHERE order_id = :order_id');

foreach ($orders as &$order) {
    $order['id'] = (int)$order['id'];
    $order['user_id'] = (int)$order['user_id'];
    $order['total_amount'] = (float)$order['total_amount'];

    $itemsStmt->execute(['order_id' => $order['id']]);
    $order['items'] = $itemsStmt->fetchAll();
    foreach ($order['items'] as &$item) {
        $item['book_id'] = (int)$item['book_id'];
        $item['price_snapshot'] = (float)$item['price_snapshot'];
        $item['quantity'] = (int)$item['quantity'];
    }
}

Response::success($orders, 'Orders retrieved successfully');
