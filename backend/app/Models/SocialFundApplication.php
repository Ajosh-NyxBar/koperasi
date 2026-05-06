<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class SocialFundApplication extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'application_number', 'member_id', 'type', 'requested_amount',
        'approved_amount', 'reason', 'attachment', 'status',
        'application_date', 'decided_date', 'decided_by', 'admin_notes',
    ];

    protected function casts(): array
    {
        return [
            'requested_amount' => 'decimal:2',
            'approved_amount' => 'decimal:2',
            'application_date' => 'date',
            'decided_date' => 'date',
        ];
    }

    public function member() { return $this->belongsTo(Member::class); }
    public function decider() { return $this->belongsTo(User::class, 'decided_by'); }
    public function disbursement() { return $this->hasOne(SocialFund::class, 'application_id'); }

    public function getAttachmentUrlAttribute(): ?string
    {
        return $this->attachment ? asset('storage/' . $this->attachment) : null;
    }
}
