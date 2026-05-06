<?php

namespace App\Http\Requests\SocialFund;

use Illuminate\Foundation\Http\FormRequest;

class StoreSocialFundRequest extends FormRequest
{
    public function authorize(): bool { return $this->user()?->isAdmin() ?? false; }

    public function rules(): array
    {
        return [
            'member_id'   => ['nullable', 'integer', 'exists:members,id'],
            'type'        => ['required', 'in:infaq,zakat,bantuan_sakit,bantuan_pendidikan,kegiatan_sosial,shu,lainnya'],
            'direction'   => ['required', 'in:in,out'],
            'amount'      => ['required', 'numeric', 'min:1000'],
            'description' => ['nullable', 'string', 'max:1000'],
        ];
    }
}
