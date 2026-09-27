<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT'], true)) {
    Response::error('Method not allowed', 405);
}

// Only Store Staff and Administrators can progress an order's status
Auth::requireRole(['staff', 'admin']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validAllowed = ['pending', 'processing', 'shipped', 'completed', 'cancelled'];
$validator = new Validator($input);
$validator->required('order_id', 'Order')->numeric('order_id')
    ->required('status', 'Status')->in('status', $validAllowed, 'Status');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$db = Database::getConnection();
$stmt = $db->prepare('UPDATE orders SET status = :status WHERE id = :id');
$stmt->execute(['status' => $input['status'], 'id' => (int)$input['order_id']]);

if ($stmt->rowCount() === 0) {
    Response::error('Order not found or status unchanged.', 404);
}

Response::success(null, 'Order status updated successfully');
