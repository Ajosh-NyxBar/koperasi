<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;

class StoreProductRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'category_id'       => ['required', 'integer', 'exists:categories,id'],
            'name'              => ['required', 'string', 'max:255'],
            'sku'               => ['nullable', 'string', 'max:50', 'unique:products,sku'],
            'description'       => ['nullable', 'string', 'max:1000'],
            'base_price'        => ['required', 'numeric', 'min:0'],
            'margin_percentage' => ['required', 'numeric', 'min:0', 'max:100'],
            'stock'             => ['nullable', 'integer', 'min:0'],
            'image'             => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
            'is_available'      => ['nullable', 'boolean'],
        ];
    }
}
