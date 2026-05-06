<?php

namespace App\Http\Requests\Financing;

use Illuminate\Foundation\Http\FormRequest;

class PayInstallmentRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'installment_id' => ['nullable', 'integer', 'exists:installments,id'],
            'amount'         => ['required', 'numeric', 'min:1000'],
            'penalty_paid'   => ['nullable', 'numeric', 'min:0'],
            'method'         => ['nullable', 'in:cash,transfer,saving_balance'],
            'notes'          => ['nullable', 'string', 'max:255'],
        ];
    }
}
