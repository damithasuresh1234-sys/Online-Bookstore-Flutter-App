<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'PUT'], true)) {
    Response::error('Method not allowed', 405);
}

$admin = Auth::requireRole(['admin']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('user_id', 'User')->numeric('user_id')
    ->required('role', 'Role')->in('role', ['customer', 'staff', 'admin'], 'Role');
if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

if ((int)$input['user_id'] === (int)$admin['sub']) {
    Response::error('You cannot change your own role.', 422);
}

$db = Database::getConnection();
$stmt = $db->prepare('UPDATE users SET role = :role WHERE id = :id');
$stmt->execute(['role' => $input['role'], 'id' => (int)$input['user_id']]);

if ($stmt->rowCount() === 0) {
    Response::error('User not found or role unchanged.', 404);
}

Response::success(null, 'User role updated successfully');
