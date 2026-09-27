<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    Response::error('Method not allowed', 405);
}

Auth::requireRole(['admin']);

$db = Database::getConnection();
$stmt = $db->query('SELECT id, name, email, role, is_active, created_at FROM users ORDER BY created_at DESC');
$users = $stmt->fetchAll();

foreach ($users as &$u) {
    $u['id'] = (int)$u['id'];
    $u['is_active'] = (bool)$u['is_active'];
}

Response::success($users, 'Users retrieved successfully');
