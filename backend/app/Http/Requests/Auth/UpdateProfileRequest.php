<?php

namespace App\Http\Requests\Auth;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateProfileRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        $userId = $this->user()->id;

        return [
            'name'             => ['sometimes', 'string', 'max:255'],
            'email'            => ['sometimes', 'email', Rule::unique('users', 'email')->ignore($userId)],
            'current_password' => ['required_with:password', 'string'],
            'password'         => ['sometimes', 'string', 'min:6', 'confirmed'],

            // Member profile fields
            'phone'            => ['nullable', 'string', 'max:20'],
            'address'          => ['nullable', 'string', 'max:500'],
            'birth_date'       => ['nullable', 'date', 'before:today'],
            'birth_place'      => ['nullable', 'string', 'max:100'],
            'occupation'       => ['nullable', 'string', 'max:255'],
            'monthly_income'   => ['nullable', 'numeric', 'min:0'],
            'photo'            => ['nullable', 'image', 'mimes:jpg,jpeg,png', 'max:2048'],
        ];
    }
}
