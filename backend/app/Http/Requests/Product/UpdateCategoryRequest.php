<?php

namespace App\Http\Requests\Product;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCategoryRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        $id = $this->route('category')?->id ?? $this->route('category');

        return [
            'name'        => ['sometimes', 'string', 'max:255', Rule::unique('categories', 'name')->ignore($id)],
            'icon'        => ['nullable', 'string', 'max:50'],
            'description' => ['nullable', 'string', 'max:500'],
            'is_active'   => ['sometimes', 'boolean'],
        ];
    }
}
