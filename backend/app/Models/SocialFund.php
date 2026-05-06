<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SocialFund extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'member_id', 'application_id', 'type', 'direction',
        'amount', 'description', 'transaction_date', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'transaction_date' => 'date',
        ];
    }

    public function member() { return $this->belongsTo(Member::class); }
    public function application() { return $this->belongsTo(SocialFundApplication::class, 'application_id'); }
    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
}
