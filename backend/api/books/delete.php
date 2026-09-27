<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Auth.php';

if (!in_array($_SERVER['REQUEST_METHOD'], ['POST', 'DELETE'], true)) {
    Response::error('Method not allowed', 405);
}

// Only an Administrator can permanently delete a book
Auth::requireRole(['admin']);

$input = json_decode(file_get_contents('php://input'), true) ?? [];
$id = isset($input['id']) ? (int)$input['id'] : (isset($_GET['id']) ? (int)$_GET['id'] : 0);

if ($id <= 0) {
    Response::error('A valid book id is required.', 422);
}

$db = Database::getConnection();
$stmt = $db->prepare('DELETE FROM books WHERE id = :id');
$stmt->execute(['id' => $id]);

if ($stmt->rowCount() === 0) {
    Response::error('Book not found.', 404);
}

Response::success(null, 'Book deleted successfully');
