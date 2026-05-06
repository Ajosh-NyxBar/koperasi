<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Member\StoreMemberRequest;
use App\Http\Requests\Member\UpdateMemberRequest;
use App\Http\Resources\MemberResource;
use App\Models\Member;
use App\Repositories\MemberRepository;
use App\Services\MemberService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MemberController extends Controller
{
    use ApiResponse;

    public function __construct(
        private MemberRepository $repo,
        private MemberService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $members = $this->repo->search(
            $request->query('search'),
            $request->query('status'),
            (int) $request->query('per_page', 20)
        );
        return $this->success([
            'items' => MemberResource::collection($members)->response()->getData(true),
        ]);
    }

    public function store(StoreMemberRequest $request): JsonResponse
    {
        $member = $this->service->create($request->validated());
        return $this->created(MemberResource::make($member), 'Anggota berhasil ditambahkan');
    }

    public function show(Member $member): JsonResponse
    {
        $member->load(['user', 'savingAccount', 'principalSaving', 'mandatorySavings', 'financings']);
        return $this->success(MemberResource::make($member));
    }

    public function update(UpdateMemberRequest $request, Member $member): JsonResponse
    {
        $updated = $this->service->update($member, $request->validated());
        return $this->success(MemberResource::make($updated), 'Data anggota berhasil diperbarui');
    }

    public function destroy(Member $member): JsonResponse
    {
        $this->service->destroy($member);
        return $this->success(null, 'Anggota berhasil dihapus');
    }
}
