<?php

namespace App\Services;

use App\Models\DeviceToken;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmService
{
    private string $projectId;
    private ?string $serviceAccountPath;

    public function __construct()
    {
        $this->projectId = config('services.firebase.project_id', '');
        $this->serviceAccountPath = config('services.firebase.credentials');
    }

    /**
     * Kirim push notification ke user tertentu
     */
    public function sendToUser(int $userId, string $title, string $body, array $data = []): void
    {
        $tokens = DeviceToken::getActiveTokensForUser($userId);

        foreach ($tokens as $token) {
            $this->sendToToken($token, $title, $body, $data);
        }
    }

    /**
     * Kirim push notification ke token tertentu
     */
    public function sendToToken(string $token, string $title, string $body, array $data = []): bool
    {
        try {
            $accessToken = $this->getAccessToken();
            if (!$accessToken) {
                Log::warning('FCM: Could not get access token');
                return false;
            }

            $response = Http::withToken($accessToken)
                ->post("https://fcm.googleapis.com/v1/projects/{$this->projectId}/messages:send", [
                    'message' => [
                        'token' => $token,
                        'notification' => [
                            'title' => $title,
                            'body' => $body,
                        ],
                        'data' => array_map('strval', $data),
                        'android' => [
                            'priority' => 'high',
                            'notification' => [
                                'channel_id' => 'kbmt_high_importance',
                                'sound' => 'default',
                            ],
                        ],
                        'apns' => [
                            'payload' => [
                                'aps' => [
                                    'sound' => 'default',
                                    'badge' => 1,
                                ],
                            ],
                        ],
                    ],
                ]);

            if ($response->failed()) {
                $error = $response->json('error.message', 'Unknown error');
                Log::warning("FCM send failed: {$error}", ['token' => substr($token, 0, 20) . '...']);

                // Jika token invalid, nonaktifkan
                if ($response->status() === 404 || str_contains($error, 'UNREGISTERED')) {
                    DeviceToken::where('token', $token)->update(['is_active' => false]);
                }

                return false;
            }

            return true;
        } catch (\Exception $e) {
            Log::error('FCM send exception: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Kirim ke multiple users
     */
    public function sendToUsers(array $userIds, string $title, string $body, array $data = []): void
    {
        foreach ($userIds as $userId) {
            $this->sendToUser($userId, $title, $body, $data);
        }
    }

    /**
     * Get OAuth2 access token dari service account
     */
    private function getAccessToken(): ?string
    {
        if (!$this->serviceAccountPath || !file_exists($this->serviceAccountPath)) {
            Log::warning('FCM: Service account file not found');
            return null;
        }

        try {
            $credentials = json_decode(file_get_contents($this->serviceAccountPath), true);

            $now = time();
            $header = base64url_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
            $payload = base64url_encode(json_encode([
                'iss' => $credentials['client_email'],
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud' => 'https://oauth2.googleapis.com/token',
                'iat' => $now,
                'exp' => $now + 3600,
            ]));

            $signature = '';
            openssl_sign(
                "$header.$payload",
                $signature,
                $credentials['private_key'],
                OPENSSL_ALGO_SHA256
            );
            $signature = base64url_encode($signature);

            $jwt = "$header.$payload.$signature";

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion' => $jwt,
            ]);

            if ($response->successful()) {
                return $response->json('access_token');
            }

            return null;
        } catch (\Exception $e) {
            Log::error('FCM getAccessToken error: ' . $e->getMessage());
            return null;
        }
    }
}

/**
 * Base64 URL-safe encode
 */
if (!function_exists('base64url_encode')) {
    function base64url_encode(string $data): string
    {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }
}
