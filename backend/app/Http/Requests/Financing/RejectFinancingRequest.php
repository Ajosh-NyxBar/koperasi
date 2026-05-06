<?php

namespace App\Http\Requests\Financing;

use Illuminate\Foundation\Http\FormRequest;

class RejectFinancingRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return ['reason' => ['required', 'string', 'min:5', 'max:1000']];
    }
}
