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
$validator->required('name', 'Name')
    ->required('email', 'Email')->email('email')
    ->required('password', 'Password')->minLength('password', 6, 'Password');

if ($validator->fails()) {
    Response::error('Validation failed', 422, $validator->getErrors());
}

$name = trim($input['name']);
$email = strtolower(trim($input['email']));
$password = $input['password'];

// Public registration always creates a Customer account.
// Staff/Admin accounts are created by an Administrator via /api/users/create.php
$role = 'customer';

$db = Database::getConnection();

$check = $db->prepare('SELECT id FROM users WHERE email = :email');
$check->execute(['email' => $email]);
if ($check->fetch()) {
    Response::error('An account with this email already exists.', 409);
}

$passwordHash = password_hash($password, PASSWORD_BCRYPT);

$stmt = $db->prepare('INSERT INTO users (name, email, password_hash, role) VALUES (:name, :email, :hash, :role)');
$stmt->execute([
    'name' => $name,
    'email' => $email,
    'hash' => $passwordHash,
    'role' => $role,
]);

$userId = (int)$db->lastInsertId();

$token = JWT::encode(['sub' => $userId, 'email' => $email, 'name' => $name, 'role' => $role]);

Response::success([
    'token' => $token,
    'user' => ['id' => $userId, 'name' => $name, 'email' => $email, 'role' => $role],
], 'Account created successfully', 201);
