<?php

namespace App\Http\Requests\Member;

use Illuminate\Foundation\Http\FormRequest;

class UpdateMemberRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'full_name'      => ['sometimes', 'string', 'max:255'],
            'phone'          => ['nullable', 'string', 'max:20'],
            'address'        => ['nullable', 'string', 'max:500'],
            'gender'         => ['sometimes', 'in:L,P'],
            'birth_date'     => ['nullable', 'date', 'before:today'],
            'birth_place'    => ['nullable', 'string', 'max:100'],
            'occupation'     => ['nullable', 'string', 'max:255'],
            'monthly_income' => ['nullable', 'numeric', 'min:0'],
            'status'         => ['sometimes', 'in:active,inactive,suspended'],
        ];
    }
}
