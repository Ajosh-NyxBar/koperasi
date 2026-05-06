<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class FinancingResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                  => $this->id,
            'contract_number'     => $this->contract_number,
            'member_id'           => $this->member_id,
            'member'              => MemberResource::make($this->whenLoaded('member')),
            'product_id'          => $this->product_id,
            'product'             => ProductResource::make($this->whenLoaded('product')),
            'item_name'           => $this->item_name,
            'base_price'          => (float) $this->base_price,
            'margin_percentage'   => (float) $this->margin_percentage,
            'margin_amount'       => (float) $this->margin_amount,
            'total_price'         => (float) $this->total_price,
            'tenor'               => (int) $this->tenor,
            'monthly_installment' => (float) $this->monthly_installment,
            'total_paid'          => (float) $this->total_paid,
            'remaining'           => (float) $this->remaining,
            'penalty_per_day'     => (float) $this->penalty_per_day,
            'progress_percentage' => $this->progress_percentage,
            'status'              => $this->status,
            'application_date'    => optional($this->application_date)->toDateString(),
            'approved_date'       => optional($this->approved_date)->toDateString(),
            'completed_date'      => optional($this->completed_date)->toDateString(),
            'notes'               => $this->notes,
            'reject_reason'       => $this->reject_reason,
            'installments'        => InstallmentResource::collection($this->whenLoaded('installments')),
            'created_at'          => $this->created_at,
        ];
    }
}
