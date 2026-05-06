<?php

namespace App\Services;

use App\Models\Member;
use App\Models\PrincipalSaving;
use App\Models\Saving;
use App\Models\User;
use App\Repositories\MemberRepository;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;

class MemberService
{
    public function __construct(private MemberRepository $repo) {}

    public function create(array $data): Member
    {
        return DB::transaction(function () use ($data) {
            $user = User::create([
                'name'     => $data['full_name'],
                'email'    => $data['email'],
                'password' => Hash::make($data['password']),
                'role'     => 'member',
            ]);

            $member = Member::create([
                'user_id'        => $user->id,
                'member_code'    => $this->repo->generateCode(),
                'full_name'      => $data['full_name'],
                'nik'            => $data['nik'],
                'phone'          => $data['phone'] ?? null,
                'address'        => $data['address'] ?? null,
                'gender'         => $data['gender'],
                'birth_date'     => $data['birth_date'] ?? null,
                'birth_place'    => $data['birth_place'] ?? null,
                'occupation'     => $data['occupation'] ?? null,
                'monthly_income' => $data['monthly_income'] ?? null,
                'join_date'      => now(),
                'status'         => 'active',
            ]);

            Saving::create(['member_id' => $member->id, 'balance' => 0]);

            $principalAmount = $data['principal_saving_amount'] ?? 100000;
            PrincipalSaving::create([
                'member_id' => $member->id,
                'amount'    => $principalAmount,
                'paid_date' => $principalAmount > 0 ? now() : null,
                'status'    => $principalAmount > 0 ? 'paid' : 'unpaid',
            ]);

            return $member->load('user');
        });
    }

    public function update(Member $member, array $data): Member
    {
        return DB::transaction(function () use ($member, $data) {
            $member->update(collect($data)->only([
                'full_name', 'phone', 'address', 'gender', 'birth_date',
                'birth_place', 'occupation', 'monthly_income', 'status',
            ])->toArray());

            if (isset($data['full_name'])) {
                $member->user->update(['name' => $data['full_name']]);
            }

            return $member->fresh()->load('user');
        });
    }

    public function destroy(Member $member): void
    {
        DB::transaction(function () use ($member) {
            $user = $member->user;
            $member->delete();
            $user?->delete();
        });
    }

    public function uploadPhoto(Member $member, $file): string
    {
        if ($member->photo) {
            Storage::disk('public')->delete($member->photo);
        }
        $path = $file->store('members', 'public');
        $member->update(['photo' => $path]);
        return $path;
    }
}
