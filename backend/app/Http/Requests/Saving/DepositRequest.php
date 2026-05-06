<?php

namespace App\Http\Requests\Saving;

use Illuminate\Foundation\Http\FormRequest;

class DepositRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'member_id'   => ['required', 'integer', 'exists:members,id'],
            'amount'      => ['required', 'numeric', 'min:1000'],
            'description' => ['nullable', 'string', 'max:255'],
        ];
    }
}
