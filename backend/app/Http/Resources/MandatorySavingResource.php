<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class MandatorySavingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'        => $this->id,
            'member_id' => $this->member_id,
            'member'    => MemberResource::make($this->whenLoaded('member')),
            'period'    => $this->period,
            'amount'    => (float) $this->amount,
            'due_date'  => optional($this->due_date)->toDateString(),
            'paid_date' => optional($this->paid_date)->toDateString(),
            'status'    => $this->status,
        ];
    }
}
