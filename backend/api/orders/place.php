<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$user = Auth::requireRole(['customer']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('shipping_address', 'Shipping address')->minLength('shipping_address', 5, 'Shipping address');
if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$db = Database::getConnection();

$cartStmt = $db->prepare('SELECT ci.id AS cart_item_id, ci.quantity, b.id AS book_id, b.title, b.price, b.stock
    FROM cart_items ci JOIN books b ON b.id = ci.book_id WHERE ci.user_id = :user_id');
$cartStmt->execute(['user_id' => $user['sub']]);
$cartItems = $cartStmt->fetchAll();

if (count($cartItems) === 0) {
    Response::error('Your cart is empty.', 422);
}

// Check stock availability for every item before committing anything
foreach ($cartItems as $item) {
    if ((int)$item['quantity'] > (int)$item['stock']) {
        Response::error("Not enough stock for \"{$item['title']}\". Available: {$item['stock']}.", 422);
    }
}

try {
    $db->beginTransaction();

    $total = 0;
    foreach ($cartItems as $item) {
        $total += $item['price'] * $item['quantity'];
    }

    $orderStmt = $db->prepare('INSERT INTO orders (user_id, total_amount, shipping_address, status)
        VALUES (:user_id, :total, :address, "pending")');
    $orderStmt->execute([
        'user_id' => $user['sub'],
        'total' => round($total, 2),
        'address' => trim($input['shipping_address']),
    ]);
    $orderId = (int)$db->lastInsertId();

    $itemStmt = $db->prepare('INSERT INTO order_items (order_id, book_id, title_snapshot, price_snapshot, quantity)
        VALUES (:order_id, :book_id, :title, :price, :quantity)');
    $stockStmt = $db->prepare('UPDATE books SET stock = stock - :quantity WHERE id = :book_id');

    foreach ($cartItems as $item) {
        $itemStmt->execute([
            'order_id' => $orderId,
            'book_id' => $item['book_id'],
            'title' => $item['title'],
            'price' => $item['price'],
            'quantity' => $item['quantity'],
        ]);
        $stockStmt->execute(['quantity' => $item['quantity'], 'book_id' => $item['book_id']]);
    }

    // Clear the cart now that the order has been placed
    $clearStmt = $db->prepare('DELETE FROM cart_items WHERE user_id = :user_id');
    $clearStmt->execute(['user_id' => $user['sub']]);

    $db->commit();

    Response::success(['order_id' => $orderId, 'total' => round($total, 2)], 'Order placed successfully', 201);
} catch (Exception $e) {
    $db->rollBack();
    Response::error('Failed to place order: ' . $e->getMessage(), 500);
}
