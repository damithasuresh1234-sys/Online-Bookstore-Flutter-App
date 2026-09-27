<?php
require_once __DIR__ . '/JWT.php';
require_once __DIR__ . '/Response.php';

class Auth
{
    /**
     * Reads the Authorization: Bearer <token> header, validates it,
     * and returns the decoded payload (user id, email, role).
     * Sends a 401 response and exits if missing/invalid.
     */
    public static function requireAuth(): array
    {
        $headers = self::getAuthHeaders();
        if (!isset($headers['Authorization'])) {
            Response::error('Missing Authorization header', 401);
        }

        $authHeader = $headers['Authorization'];
        if (!preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            Response::error('Invalid Authorization header format', 401);
        }

        $token = $matches[1];
        $payload = JWT::decode($token);

        if ($payload === null) {
            Response::error('Invalid or expired token', 401);
        }

        return $payload;
    }

    /**
     * Same as requireAuth() but also checks the user's role is in $allowedRoles.
     * Example: Auth::requireRole(['staff', 'admin']);
     */
    public static function requireRole(array $allowedRoles): array
    {
        $payload = self::requireAuth();
        if (!in_array($payload['role'], $allowedRoles, true)) {
            Response::error('Forbidden: insufficient permissions for this action', 403);
        }
        return $payload;
    }

    private static function getAuthHeaders(): array
    {
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            if (isset($headers['Authorization'])) return $headers;
            // Some servers use lowercase
            if (isset($headers['authorization'])) return ['Authorization' => $headers['authorization']];
        }
        // Fallback for servers where getallheaders() isn't available
        if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
            return ['Authorization' => $_SERVER['HTTP_AUTHORIZATION']];
        }
        return [];
    }
}
