<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Financing extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'contract_number', 'member_id', 'product_id', 'item_name',
        'base_price', 'margin_percentage', 'margin_amount', 'total_price',
        'tenor', 'monthly_installment', 'total_paid', 'remaining',
        'penalty_per_day', 'status',
        'application_date', 'approved_date', 'completed_date', 'approved_by',
        'notes', 'reject_reason',
    ];

    protected function casts(): array
    {
        return [
            'base_price' => 'decimal:2',
            'margin_percentage' => 'decimal:2',
            'margin_amount' => 'decimal:2',
            'total_price' => 'decimal:2',
            'monthly_installment' => 'decimal:2',
            'total_paid' => 'decimal:2',
            'remaining' => 'decimal:2',
            'penalty_per_day' => 'decimal:2',
            'application_date' => 'date',
            'approved_date' => 'date',
            'completed_date' => 'date',
        ];
    }

    protected $appends = ['progress_percentage'];

    public function member() { return $this->belongsTo(Member::class); }
    public function product() { return $this->belongsTo(Product::class); }
    public function installments() { return $this->hasMany(Installment::class)->orderBy('installment_number'); }
    public function payments() { return $this->hasMany(InstallmentPayment::class); }
    public function approver() { return $this->belongsTo(User::class, 'approved_by'); }

    public function getProgressPercentageAttribute(): float
    {
        $total = (float) $this->total_price;
        if ($total <= 0) return 0;
        return round(((float) $this->total_paid / $total) * 100, 2);
    }
}
