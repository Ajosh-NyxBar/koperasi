<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InstallmentResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                 => $this->id,
            'financing_id'       => $this->financing_id,
            'installment_number' => (int) $this->installment_number,
            'amount'             => (float) $this->amount,
            'penalty_amount'     => (float) $this->penalty_amount,
            'paid_amount'        => (float) $this->paid_amount,
            'due_date'           => optional($this->due_date)->toDateString(),
            'paid_date'          => optional($this->paid_date)->toDateString(),
            'status'             => $this->status,
            'is_overdue'         => $this->isOverdue(),
        ];
    }
}
