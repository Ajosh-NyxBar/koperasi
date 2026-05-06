<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SavingTransactionResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'type'             => $this->type,
            'type_label'       => $this->type === 'deposit' ? 'Setoran' : 'Penarikan',
            'amount'           => (float) $this->amount,
            'balance_after'    => (float) $this->balance_after,
            'reference'        => $this->reference,
            'description'      => $this->description,
            'transaction_date' => optional($this->transaction_date)->toDateString(),
            'created_at'       => $this->created_at,
        ];
    }
}
