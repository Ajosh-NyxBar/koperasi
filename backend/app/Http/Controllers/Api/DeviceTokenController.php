<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\DeviceToken;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DeviceTokenController extends Controller
{
    use ApiResponse;

    /**
     * Register atau update device token
     */
    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string'],
            'platform' => ['required', 'in:android,ios'],
        ]);

        $user = $request->user();

        // Upsert: jika token sudah ada, update user_id dan aktifkan
        DeviceToken::updateOrCreate(
            ['token' => $data['token']],
            [
                'user_id' => $user->id,
                'platform' => $data['platform'],
                'is_active' => true,
                'last_used_at' => now(),
            ]
        );

        return $this->success(null, 'Device token berhasil didaftarkan');
    }

    /**
     * Hapus device token (saat logout)
     */
    public function destroy(Request $request): JsonResponse
    {
        $data = $request->validate([
            'token' => ['required', 'string'],
        ]);

        DeviceToken::where('token', $data['token'])->update(['is_active' => false]);

        return $this->success(null, 'Device token berhasil dihapus');
    }
}
