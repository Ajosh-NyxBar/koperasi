<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Installment extends Model
{
    protected $fillable = [
        'financing_id', 'installment_number', 'amount', 'penalty_amount',
        'paid_amount', 'due_date', 'paid_date', 'status',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'penalty_amount' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'due_date' => 'date',
            'paid_date' => 'date',
        ];
    }

    public function financing() { return $this->belongsTo(Financing::class); }
    public function payments() { return $this->hasMany(InstallmentPayment::class); }

    public function isOverdue(): bool
    {
        return in_array($this->status, ['pending', 'partial']) && $this->due_date->isPast();
    }

    public function calculatePenalty(?\Carbon\Carbon $asOf = null): float
    {
        $asOf = $asOf ?? now();
        if (in_array($this->status, ['paid'])) return 0;
        if ($this->due_date >= $asOf) return 0;
        $days = $this->due_date->diffInDays($asOf);
        return round((float) $this->financing->penalty_per_day * $days, 2);
    }
}
