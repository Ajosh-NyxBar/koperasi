<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MandatorySaving extends Model
{
    protected $fillable = [
        'member_id', 'period', 'amount', 'due_date', 'paid_date', 'status', 'paid_by',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'due_date' => 'date',
            'paid_date' => 'date',
        ];
    }

    public function member() { return $this->belongsTo(Member::class); }
    public function paidBy() { return $this->belongsTo(User::class, 'paid_by'); }

    public function scopeUnpaid($q) { return $q->whereIn('status', ['unpaid', 'overdue']); }
    public function scopePaid($q) { return $q->where('status', 'paid'); }
}
