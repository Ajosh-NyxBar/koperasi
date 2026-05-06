<?php

namespace App\Http\Requests\SocialFund;

use Illuminate\Foundation\Http\FormRequest;

class DecideApplicationRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'decision'        => ['required', 'in:approved,rejected'],
            'approved_amount' => ['required_if:decision,approved', 'numeric', 'min:1000'],
            'admin_notes'     => ['nullable', 'string', 'max:1000'],
        ];
    }
}
