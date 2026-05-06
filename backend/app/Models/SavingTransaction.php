<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SavingTransaction extends Model
{
    protected $fillable = [
        'saving_id', 'type', 'amount', 'balance_after', 'reference',
        'description', 'transaction_date', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'balance_after' => 'decimal:2',
            'transaction_date' => 'date',
        ];
    }

    public function savingAccount() { return $this->belongsTo(Saving::class, 'saving_id'); }
    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
}
