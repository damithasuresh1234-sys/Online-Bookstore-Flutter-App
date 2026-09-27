<?php
/**
 * Minimal JWT (HS256) implementation so the project runs on plain XAMPP
 * without requiring Composer / firebase/php-jwt.
 *
 * For a real production system you would use a maintained library,
 * but for an assignment demonstrating the API/auth flow this is sufficient
 * and easy to explain in a report.
 */
class JWT
{
    // Change this secret in a real deployment (e.g. load from an env file)
    private static $secret = 'CHANGE_THIS_SECRET_BOOKSTORE_2026';
    private static $expirySeconds = 60 * 60 * 24; // 24 hours

    public static function encode(array $payload): string
    {
        $header = ['typ' => 'JWT', 'alg' => 'HS256'];
        $payload['iat'] = time();
        $payload['exp'] = time() + self::$expirySeconds;

        $headerEncoded = self::base64UrlEncode(json_encode($header));
        $payloadEncoded = self::base64UrlEncode(json_encode($payload));

        $signature = hash_hmac('sha256', "$headerEncoded.$payloadEncoded", self::$secret, true);
        $signatureEncoded = self::base64UrlEncode($signature);

        return "$headerEncoded.$payloadEncoded.$signatureEncoded";
    }

    /**
     * Returns the decoded payload array on success, or null if invalid/expired.
     */
    public static function decode(string $jwt): ?array
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) return null;

        [$headerEncoded, $payloadEncoded, $signatureEncoded] = $parts;

        $expectedSignature = self::base64UrlEncode(
            hash_hmac('sha256', "$headerEncoded.$payloadEncoded", self::$secret, true)
        );

        if (!hash_equals($expectedSignature, $signatureEncoded)) {
            return null; // signature mismatch / tampered token
        }

        $payload = json_decode(self::base64UrlDecode($payloadEncoded), true);
        if (!$payload) return null;

        if (isset($payload['exp']) && time() > $payload['exp']) {
            return null; // expired
        }

        return $payload;
    }

    private static function base64UrlEncode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string
    {
        $remainder = strlen($data) % 4;
        if ($remainder) {
            $data .= str_repeat('=', 4 - $remainder);
        }
        return base64_decode(strtr($data, '-_', '+/'));
    }
}
