<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                => $this->id,
            'category_id'       => $this->category_id,
            'category'          => CategoryResource::make($this->whenLoaded('category')),
            'name'              => $this->name,
            'sku'               => $this->sku,
            'description'       => $this->description,
            'base_price'        => (float) $this->base_price,
            'margin_percentage' => (float) $this->margin_percentage,
            'selling_price'     => (float) $this->selling_price,
            'stock'             => (int) $this->stock,
            'image'             => $this->image,
            'image_url'         => $this->image_url,
            'is_available'      => (bool) $this->is_available,
        ];
    }
}
