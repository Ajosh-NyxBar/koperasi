<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class InstallmentPayment extends Model
{
    protected $fillable = [
        'installment_id', 'financing_id', 'receipt_number', 'amount',
        'penalty_paid', 'payment_date', 'method', 'notes', 'received_by',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'penalty_paid' => 'decimal:2',
            'payment_date' => 'date',
        ];
    }

    public function installment() { return $this->belongsTo(Installment::class); }
    public function financing() { return $this->belongsTo(Financing::class); }
    public function receiver() { return $this->belongsTo(User::class, 'received_by'); }
}
