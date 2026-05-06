<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MemberResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'user_id'        => $this->user_id,
            'member_code'    => $this->member_code,
            'full_name'      => $this->full_name,
            'nik'            => $this->nik,
            'phone'          => $this->phone,
            'address'        => $this->address,
            'gender'         => $this->gender,
            'gender_label'   => $this->gender === 'L' ? 'Laki-laki' : 'Perempuan',
            'birth_date'     => optional($this->birth_date)->toDateString(),
            'birth_place'    => $this->birth_place,
            'occupation'     => $this->occupation,
            'monthly_income' => $this->monthly_income,
            'join_date'      => optional($this->join_date)->toDateString(),
            'status'         => $this->status,
            'photo'          => $this->photo,
            'photo_url'      => $this->photo_url,
            'email'          => $this->whenLoaded('user', fn() => $this->user->email),
            'created_at'     => $this->created_at,
        ];
    }
}
