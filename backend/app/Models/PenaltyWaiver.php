<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PenaltyWaiver extends Model
{
    protected $fillable = [
        'installment_id', 'financing_id', 'original_penalty',
        'waived_amount', 'final_penalty', 'reason', 'waived_by',
    ];

    protected function casts(): array
    {
        return [
            'original_penalty' => 'decimal:2',
            'waived_amount' => 'decimal:2',
            'final_penalty' => 'decimal:2',
        ];
    }

    public function installment() { return $this->belongsTo(Installment::class); }
    public function financing() { return $this->belongsTo(Financing::class); }
    public function waivedByUser() { return $this->belongsTo(User::class, 'waived_by'); }
}
