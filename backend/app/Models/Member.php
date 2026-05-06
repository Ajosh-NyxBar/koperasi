<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Member extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'user_id', 'member_code', 'full_name', 'nik', 'phone', 'address',
        'gender', 'birth_date', 'birth_place', 'occupation', 'monthly_income',
        'join_date', 'status', 'photo',
    ];

    protected function casts(): array
    {
        return [
            'birth_date' => 'date',
            'join_date' => 'date',
            'monthly_income' => 'decimal:2',
        ];
    }

    public function user() { return $this->belongsTo(User::class); }
    public function savingAccount() { return $this->hasOne(Saving::class); }
    public function principalSaving() { return $this->hasOne(PrincipalSaving::class); }
    public function mandatorySavings() { return $this->hasMany(MandatorySaving::class); }
    public function financings() { return $this->hasMany(Financing::class); }
    public function socialFunds() { return $this->hasMany(SocialFund::class); }
    public function socialFundApplications() { return $this->hasMany(SocialFundApplication::class); }

    public function scopeActive($q) { return $q->where('status', 'active'); }
    public function scopeSearch($q, ?string $term) {
        if (!$term) return $q;
        return $q->where(fn($w) => $w->where('full_name', 'like', "%{$term}%")
            ->orWhere('member_code', 'like', "%{$term}%")
            ->orWhere('nik', 'like', "%{$term}%")
            ->orWhere('phone', 'like', "%{$term}%"));
    }

    public function getPhotoUrlAttribute(): ?string
    {
        return $this->photo ? asset('storage/' . $this->photo) : null;
    }
}
