<?php

namespace App\Repositories;

use App\Models\Financing;
use Illuminate\Pagination\LengthAwarePaginator;

class FinancingRepository extends BaseRepository
{
    public function __construct(Financing $model) { parent::__construct($model); }

    public function listForMember(?int $memberId, ?string $status = null, int $perPage = 20): LengthAwarePaginator
    {
        return $this->query()
            ->with(['member', 'product'])
            ->when($memberId, fn($q) => $q->where('member_id', $memberId))
            ->when($status, fn($q) => $q->where('status', $status))
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }

    public function generateContractNumber(): string
    {
        $next = (Financing::withTrashed()->max('id') ?? 0) + 1;
        return 'FIN-' . now()->format('Ym') . '-' . str_pad((string) $next, 5, '0', STR_PAD_LEFT);
    }
}
