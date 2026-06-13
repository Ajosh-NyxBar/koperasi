<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DeviceToken extends Model
{
    protected $fillable = [
        'user_id', 'token', 'platform', 'is_active', 'last_used_at',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'last_used_at' => 'datetime',
        ];
    }

    public function user() { return $this->belongsTo(User::class); }

    /**
     * Get active tokens for a user
     */
    public static function getActiveTokensForUser(int $userId): array
    {
        return static::where('user_id', $userId)
            ->where('is_active', true)
            ->pluck('token')
            ->toArray();
    }
}
