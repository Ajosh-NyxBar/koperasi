<?php

namespace App\Http\Requests\Financing;

use Illuminate\Foundation\Http\FormRequest;

class StoreFinancingRequest extends FormRequest
{
    public function authorize(): bool { return true; } // member or admin

    public function rules(): array
    {
        $isAdmin = $this->user()?->isAdmin() ?? false;

        return [
            // Admin wajib pilih member; member otomatis pakai member_id miliknya
            'member_id'         => [$isAdmin ? 'required' : 'nullable', 'integer', 'exists:members,id'],
            'product_id'        => ['nullable', 'integer', 'exists:products,id'],
            'item_name'         => ['required', 'string', 'max:255'],
            'base_price'        => ['required', 'numeric', 'min:1000'],
            'margin_percentage' => ['required', 'numeric', 'min:0', 'max:100'],
            'tenor'             => ['required', 'integer', 'min:1', 'max:60'],
            'penalty_per_day'   => ['nullable', 'numeric', 'min:0'],
            'notes'             => ['nullable', 'string', 'max:1000'],
        ];
    }
}
