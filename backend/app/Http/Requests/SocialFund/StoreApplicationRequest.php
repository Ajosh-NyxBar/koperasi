<?php

namespace App\Http\Requests\SocialFund;

use Illuminate\Foundation\Http\FormRequest;

class StoreApplicationRequest extends FormRequest
{
    public function authorize(): bool { return true; }

    public function rules(): array
    {
        return [
            'type'             => ['required', 'in:bantuan_sakit,bantuan_pendidikan,kegiatan_sosial,lainnya'],
            'requested_amount' => ['required', 'numeric', 'min:10000'],
            'reason'           => ['required', 'string', 'min:10', 'max:1000'],
            'attachment'       => ['nullable', 'file', 'mimes:jpg,jpeg,png,pdf', 'max:4096'],
        ];
    }
}
