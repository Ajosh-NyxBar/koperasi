<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PenaltySetting extends Model
{
    protected $fillable = [
        'name', 'penalty_per_day', 'grace_period_days',
        'max_penalty_percentage', 'is_default', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'penalty_per_day' => 'decimal:2',
            'max_penalty_percentage' => 'decimal:2',
            'grace_period_days' => 'integer',
            'is_default' => 'boolean',
            'is_active' => 'boolean',
        ];
    }

    public static function getDefault(): ?self
    {
        return static::where('is_default', true)->where('is_active', true)->first();
    }
}
