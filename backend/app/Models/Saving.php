<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Saving extends Model
{
    protected $fillable = ['member_id', 'balance'];
    protected $casts = ['balance' => 'decimal:2'];

    public function member() { return $this->belongsTo(Member::class); }
    public function transactions() { return $this->hasMany(SavingTransaction::class); }
}
