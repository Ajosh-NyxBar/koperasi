<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;

class RegisterRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'full_name'      => ['required', 'string', 'max:255'],
            'email'          => ['required', 'email', 'max:255', 'unique:users,email'],
            'password'       => ['required', 'string', 'min:6', 'confirmed'],
            'nik'            => ['required', 'string', 'size:16', 'unique:members,nik'],
            'phone'          => ['nullable', 'string', 'max:20'],
            'address'        => ['nullable', 'string', 'max:500'],
            'gender'         => ['required', 'in:L,P'],
            'birth_date'     => ['nullable', 'date', 'before:today'],
            'birth_place'    => ['nullable', 'string', 'max:100'],
            'occupation'     => ['nullable', 'string', 'max:255'],
            'monthly_income' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    public function messages(): array
    {
        return [
            'nik.size' => 'NIK harus 16 digit.',
            'password.confirmed' => 'Konfirmasi password tidak cocok.',
        ];
    }
}
