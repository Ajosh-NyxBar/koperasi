<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Product extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'category_id', 'name', 'sku', 'description', 'base_price',
        'margin_percentage', 'stock', 'image', 'is_available',
    ];

    protected function casts(): array
    {
        return [
            'base_price' => 'decimal:2',
            'margin_percentage' => 'decimal:2',
            'is_available' => 'boolean',
        ];
    }

    protected $appends = ['selling_price', 'image_url'];

    public function category() { return $this->belongsTo(Category::class); }
    public function financings() { return $this->hasMany(Financing::class); }

    public function getSellingPriceAttribute(): float
    {
        return (float) $this->base_price + ((float) $this->base_price * (float) $this->margin_percentage / 100);
    }

    public function getImageUrlAttribute(): ?string
    {
        return $this->image ? asset('storage/' . $this->image) : null;
    }

    public function scopeAvailable($q) { return $q->where('is_available', true); }
}
