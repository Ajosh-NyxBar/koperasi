<?php

namespace App\Http\Requests\Member;

use Illuminate\Foundation\Http\FormRequest;

class StoreMemberRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'full_name'                => ['required', 'string', 'max:255'],
            'email'                    => ['required', 'email', 'unique:users,email'],
            'password'                 => ['required', 'string', 'min:6'],
            'nik'                      => ['required', 'string', 'size:16', 'unique:members,nik'],
            'phone'                    => ['nullable', 'string', 'max:20'],
            'address'                  => ['nullable', 'string', 'max:500'],
            'gender'                   => ['required', 'in:L,P'],
            'birth_date'               => ['nullable', 'date', 'before:today'],
            'birth_place'              => ['nullable', 'string', 'max:100'],
            'occupation'               => ['nullable', 'string', 'max:255'],
            'monthly_income'           => ['nullable', 'numeric', 'min:0'],
            'principal_saving_amount'  => ['nullable', 'numeric', 'min:0'],
        ];
    }
}
