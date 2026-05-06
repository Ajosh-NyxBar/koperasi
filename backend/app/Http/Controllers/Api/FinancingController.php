<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Financing\PayInstallmentRequest;
use App\Http\Requests\Financing\RejectFinancingRequest;
use App\Http\Requests\Financing\SimulateFinancingRequest;
use App\Http\Requests\Financing\StoreFinancingRequest;
use App\Http\Resources\FinancingResource;
use App\Http\Resources\InstallmentResource;
use App\Models\Financing;
use App\Repositories\FinancingRepository;
use App\Services\FinancingService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FinancingController extends Controller
{
    use ApiResponse;

    public function __construct(
        private FinancingRepository $repo,
        private FinancingService $service,
    ) {}

    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $memberId = $user->isAdmin() ? null : $user->member?->id;
        $items = $this->repo->listForMember($memberId, $request->query('status'));
        return $this->success(FinancingResource::collection($items)->response()->getData(true));
    }

    public function show(Financing $financing, Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->isAdmin() && $financing->member_id !== $user->member?->id) {
            return $this->error('Tidak diizinkan', 403);
        }
        $financing->load(['member', 'product', 'installments']);
        return $this->success(FinancingResource::make($financing));
    }

    public function simulate(SimulateFinancingRequest $request): JsonResponse
    {
        $sim = $this->service->simulate(
            (float) $request->base_price,
            (float) $request->margin_percentage,
            (int) $request->tenor,
        );
        return $this->success($sim);
    }

    public function store(StoreFinancingRequest $request): JsonResponse
    {
        $data = $request->validated();
        if (!$request->user()->isAdmin()) {
            $memberId = $request->user()->member?->id;
            if (!$memberId) return $this->error('Profil anggota tidak ditemukan', 422);
            $data['member_id'] = $memberId;
        }
        $financing = $this->service->createApplication($data);
        return $this->created(FinancingResource::make($financing), 'Pengajuan pembiayaan berhasil dikirim');
    }

    public function approve(Financing $financing, Request $request): JsonResponse
    {
        $financing = $this->service->approve($financing, $request->user()->id);
        return $this->success(FinancingResource::make($financing), 'Pembiayaan disetujui');
    }

    public function reject(RejectFinancingRequest $request, Financing $financing): JsonResponse
    {
        $financing = $this->service->reject($financing, $request->reason, $request->user()->id);
        return $this->success(FinancingResource::make($financing), 'Pembiayaan ditolak');
    }

    public function payInstallment(PayInstallmentRequest $request, Financing $financing): JsonResponse
    {
        $result = $this->service->payInstallment(
            $financing,
            $request->installment_id,
            (float) $request->amount,
            (float) ($request->penalty_paid ?? 0),
            $request->method ?? 'cash',
            $request->notes,
            $request->user()->id,
        );
        return $this->success([
            'financing' => FinancingResource::make($result['financing']),
            'payment'   => $result['payment'],
        ], 'Cicilan berhasil dibayar');
    }

    public function installments(Financing $financing, Request $request): JsonResponse
    {
        $user = $request->user();
        if (!$user->isAdmin() && $financing->member_id !== $user->member?->id) {
            return $this->error('Tidak diizinkan', 403);
        }
        return $this->success(InstallmentResource::collection($financing->installments));
    }
}
