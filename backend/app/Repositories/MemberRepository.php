<?php

namespace App\Repositories;

use App\Models\Member;
use Illuminate\Pagination\LengthAwarePaginator;

class MemberRepository extends BaseRepository
{
    public function __construct(Member $model) { parent::__construct($model); }

    public function search(?string $term, ?string $status = null, int $perPage = 20): LengthAwarePaginator
    {
        return $this->query()
            ->with('user')
            ->search($term)
            ->when($status, fn($q) => $q->where('status', $status))
            ->orderBy('full_name')
            ->paginate($perPage);
    }

    public function generateCode(): string
    {
        $next = (Member::withTrashed()->max('id') ?? 0) + 1;
        return 'KBMT-' . str_pad((string) $next, 5, '0', STR_PAD_LEFT);
    }
}
