<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProductRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        $id = $this->route('product')?->id ?? $this->route('product');

        return [
            'category_id'       => ['sometimes', 'integer', 'exists:categories,id'],
            'name'              => ['sometimes', 'string', 'max:255'],
            'sku'               => ['nullable', 'string', 'max:50', Rule::unique('products', 'sku')->ignore($id)],
            'description'       => ['nullable', 'string', 'max:1000'],
            'base_price'        => ['sometimes', 'numeric', 'min:0'],
            'margin_percentage' => ['sometimes', 'numeric', 'min:0', 'max:100'],
            'stock'             => ['sometimes', 'integer', 'min:0'],
            'image'             => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
            'is_available'      => ['sometimes', 'boolean'],
        ];
    }
}
