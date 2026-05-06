<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SocialFundResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'member_id'        => $this->member_id,
            'member'           => MemberResource::make($this->whenLoaded('member')),
            'application_id'   => $this->application_id,
            'type'             => $this->type,
            'direction'        => $this->direction,
            'amount'           => (float) $this->amount,
            'description'      => $this->description,
            'transaction_date' => optional($this->transaction_date)->toDateString(),
            'created_at'       => $this->created_at,
        ];
    }
}
