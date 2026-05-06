<?php

namespace App\Repositories;

use App\Models\Saving;

class SavingRepository extends BaseRepository
{
    public function __construct(Saving $model) { parent::__construct($model); }

    public function firstOrCreateForMember(int $memberId): Saving
    {
        return Saving::firstOrCreate(['member_id' => $memberId], ['balance' => 0]);
    }
}
