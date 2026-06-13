<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Installment extends Model
{
    protected $fillable = [
        'financing_id', 'installment_number', 'amount', 'penalty_amount',
        'waived_penalty', 'paid_amount', 'due_date', 'paid_date', 'status',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'penalty_amount' => 'decimal:2',
            'waived_penalty' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'due_date' => 'date',
            'paid_date' => 'date',
        ];
    }

    public function financing() { return $this->belongsTo(Financing::class); }
    public function payments() { return $this->hasMany(InstallmentPayment::class); }
    public function waivers() { return $this->hasMany(PenaltyWaiver::class); }

    public function isOverdue(): bool
    {
        return in_array($this->status, ['pending', 'partial']) && $this->due_date->isPast();
    }

    /**
     * Hitung denda real-time dengan mempertimbangkan:
     * - Grace period (hari toleransi)
     * - Max penalty percentage (batas maksimal denda)
     * - Waived penalty (keringanan yang sudah diberikan)
     */
    public function calculatePenalty(?\Carbon\Carbon $asOf = null): float
    {
        $asOf = $asOf ?? now();
        if (in_array($this->status, ['paid'])) return 0;
        if ($this->due_date >= $asOf) return 0;

        $financing = $this->financing;
        $penaltyPerDay = (float) $financing->penalty_per_day;

        // Ambil setting default jika ada
        $setting = PenaltySetting::getDefault();
        $gracePeriod = $setting ? $setting->grace_period_days : 0;
        $maxPercentage = $setting ? (float) $setting->max_penalty_percentage : 0;

        // Hitung hari keterlambatan dikurangi grace period
        $totalDays = $this->due_date->diffInDays($asOf);
        $effectiveDays = max(0, $totalDays - $gracePeriod);

        if ($effectiveDays <= 0) return 0;

        $penalty = round($penaltyPerDay * $effectiveDays, 2);

        // Terapkan batas maksimal jika ada
        if ($maxPercentage > 0) {
            $maxPenalty = (float) $this->amount * $maxPercentage / 100;
            $penalty = min($penalty, $maxPenalty);
        }

        // Kurangi dengan keringanan yang sudah diberikan
        $penalty = max(0, $penalty - (float) $this->waived_penalty);

        return $penalty;
    }

    /**
     * Total denda yang harus dibayar (real-time - yang sudah dibayar)
     */
    public function getOutstandingPenalty(?\Carbon\Carbon $asOf = null): float
    {
        $calculated = $this->calculatePenalty($asOf);
        $alreadyPaid = (float) $this->penalty_amount;
        return max(0, $calculated - $alreadyPaid);
    }
}
