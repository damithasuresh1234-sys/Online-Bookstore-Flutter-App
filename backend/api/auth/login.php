<?php
require_once __DIR__ . '/../../config/cors.php';
require_once __DIR__ . '/../../config/database.php';
require_once __DIR__ . '/../../helpers/Response.php';
require_once __DIR__ . '/../../helpers/Validator.php';
require_once __DIR__ . '/../../helpers/JWT.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    Response::error('Method not allowed', 405);
}

$input = json_decode(file_get_contents('php://input'), true) ?? [];

$validator = new Validator($input);
$validator->required('email', 'Email')->required('password', 'Password');
if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$email = strtolower(trim($input['email']));
$password = $input['password'];

$db = Database::getConnection();
$stmt = $db->prepare('SELECT * FROM users WHERE email = :email');
$stmt->execute(['email' => $email]);
$user = $stmt->fetch();

if (!$user || !password_verify($password, $user['password_hash'])) {
    Response::error('Invalid email or password.', 401);
}

if ((int)$user['is_active'] === 0) {
    Response::error('This account has been disabled. Contact an administrator.', 403);
}

$token = JWT::encode([
    'sub' => (int)$user['id'],
    'email' => $user['email'],
    'name' => $user['name'],
    'role' => $user['role'],
]);

Response::success([
    'token' => $token,
    'user' => [
        'id' => (int)$user['id'],
        'name' => $user['name'],
        'email' => $user['email'],
        'role' => $user['role'],
    ],
], 'Login successful');
