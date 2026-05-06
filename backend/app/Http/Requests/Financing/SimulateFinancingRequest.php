<?php

namespace App\Http\Requests\Financing;

use Illuminate\Foundation\Http\FormRequest;

class SimulateFinancingRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'base_price'        => ['required', 'numeric', 'min:1000'],
            'margin_percentage' => ['required', 'numeric', 'min:0', 'max:100'],
            'tenor'             => ['required', 'integer', 'min:1', 'max:60'],
        ];
    }
}
