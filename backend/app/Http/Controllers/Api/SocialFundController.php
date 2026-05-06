<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\SocialFund\DecideApplicationRequest;
use App\Http\Requests\SocialFund\StoreApplicationRequest;
use App\Http\Requests\SocialFund\StoreSocialFundRequest;
use App\Http\Resources\SocialFundApplicationResource;
use App\Http\Resources\SocialFundResource;
use App\Models\SocialFund;
use App\Models\SocialFundApplication;
use App\Services\SocialFundService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SocialFundController extends Controller
{
    use ApiResponse;

    public function __construct(private SocialFundService $service) {}

    // ---------- Kas dana sosial ----------

    public function index(Request $request): JsonResponse
    {
        $q = SocialFund::with('member');
        if ($request->filled('type')) $q->where('type', $request->type);
        if ($request->filled('direction')) $q->where('direction', $request->direction);
        $items = $q->orderByDesc('transaction_date')->paginate(20);

        $totalIn = SocialFund::where('direction', 'in')->sum('amount');
        $totalOut = SocialFund::where('direction', 'out')->sum('amount');

        return $this->success([
            'funds'     => SocialFundResource::collection($items)->response()->getData(true),
            'total_in'  => (float) $totalIn,
            'total_out' => (float) $totalOut,
            'balance'   => (float) ($totalIn - $totalOut),
        ]);
    }

    public function store(StoreSocialFundRequest $request): JsonResponse
    {
        $fund = $this->service->recordTransaction($request->validated(), $request->user()->id);
        return $this->created(SocialFundResource::make($fund), 'Dana sosial berhasil dicatat');
    }

    // ---------- Pengajuan bantuan ----------

    public function applications(Request $request): JsonResponse
    {
        $user = $request->user();
        $q = SocialFundApplication::with('member');
        if (!$user->isAdmin()) {
            $q->where('member_id', $user->member?->id ?? 0);
        }
        if ($request->filled('status')) $q->where('status', $request->status);
        $items = $q->orderByDesc('application_date')->paginate(20);
        return $this->success(SocialFundApplicationResource::collection($items)->response()->getData(true));
    }

    public function showApplication(SocialFundApplication $application, Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->isAdmin() && $application->member_id !== $user->member?->id) {
            return $this->error('Tidak diizinkan', 403);
        }
        return $this->success(SocialFundApplicationResource::make($application->load('member')));
    }

    public function storeApplication(StoreApplicationRequest $request): JsonResponse
    {
        $member = $request->user()->member;
        if (!$member) return $this->error('Profil anggota tidak ditemukan', 422);

        $app = $this->service->applyForAid($member->id, $request->validated(), $request->file('attachment'));
        return $this->created(SocialFundApplicationResource::make($app), 'Pengajuan bantuan terkirim');
    }

    public function decideApplication(DecideApplicationRequest $request, SocialFundApplication $application): JsonResponse
    {
        $app = $this->service->decide(
            $application,
            $request->decision,
            $request->approved_amount ? (float) $request->approved_amount : null,
            $request->admin_notes,
            $request->user()->id,
        );
        return $this->success(SocialFundApplicationResource::make($app), 'Keputusan tersimpan');
    }
}
