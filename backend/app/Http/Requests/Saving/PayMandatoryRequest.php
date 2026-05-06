<?php

namespace App\Http\Requests\Saving;

use Illuminate\Foundation\Http\FormRequest;

class PayMandatoryRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'member_id' => ['required', 'integer', 'exists:members,id'],
            'amount'    => ['required', 'numeric', 'min:1000'],
            'period'    => ['required', 'string', 'regex:/^\d{4}-\d{2}$/'],
        ];
    }

    public function messages(): array
    {
        return ['period.regex' => 'Format periode harus YYYY-MM (contoh 2024-05).'];
    }
}
