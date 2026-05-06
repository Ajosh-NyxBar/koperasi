<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SocialFundApplicationResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'application_number' => $this->application_number,
            'member_id'          => $this->member_id,
            'member'             => MemberResource::make($this->whenLoaded('member')),
            'type'               => $this->type,
            'requested_amount'   => (float) $this->requested_amount,
            'approved_amount'    => $this->approved_amount !== null ? (float) $this->approved_amount : null,
            'reason'             => $this->reason,
            'attachment'         => $this->attachment,
            'attachment_url'     => $this->attachment_url,
            'status'             => $this->status,
            'application_date'   => optional($this->application_date)->toDateString(),
            'decided_date'       => optional($this->decided_date)->toDateString(),
            'admin_notes'        => $this->admin_notes,
            'created_at'         => $this->created_at,
        ];
    }
}
