<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PrincipalSaving extends Model
{
    protected $fillable = ['member_id', 'amount', 'paid_date', 'status'];

    protected function casts(): array
    {
        return ['amount' => 'decimal:2', 'paid_date' => 'date'];
    }

    public function member() { return $this->belongsTo(Member::class); }
}
