<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Saving\DepositRequest;
use App\Http\Requests\Saving\PayMandatoryRequest;
use App\Http\Requests\Saving\WithdrawRequest;
use App\Http\Resources\MandatorySavingResource;
use App\Http\Resources\SavingTransactionResource;
use App\Models\MandatorySaving;
use App\Models\Saving;
use App\Services\SavingService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class SavingController extends Controller
{
    use ApiResponse;

    public function __construct(private SavingService $service) {}

    // ============== MEMBER ==============

    public function balance(Request $request): JsonResponse
    {
        $member = $request->user()->member;
        if (!$member) return $this->error('Data anggota tidak ditemukan', 404);

        $saving = $member->savingAccount;
        $type = $request->query('type'); // deposit/withdrawal
        $from = $request->query('from');
        $to = $request->query('to');

        $tx = $saving
            ? $saving->transactions()
                ->when($type, fn($q) => $q->where('type', $type))
                ->when($from, fn($q) => $q->whereDate('transaction_date', '>=', $from))
                ->when($to, fn($q) => $q->whereDate('transaction_date', '<=', $to))
                ->orderByDesc('transaction_date')
                ->paginate(20)
            : collect();

        return $this->success([
            'balance' => $saving?->balance ?? 0,
            'transactions' => $saving ? SavingTransactionResource::collection($tx)->response()->getData(true) : [],
        ]);
    }

    public function mandatorySavings(Request $request): JsonResponse
    {
        $member = $request->user()->member;
        if (!$member) return $this->error('Data anggota tidak ditemukan', 404);

        $savings = $member->mandatorySavings()->orderByDesc('period')->paginate(20);
        $totalPaid = $member->mandatorySavings()->where('status', 'paid')->sum('amount');

        return $this->success([
            'total_paid' => (float) $totalPaid,
            'items' => MandatorySavingResource::collection($savings)->response()->getData(true),
        ]);
    }

    public function principalSaving(Request $request): JsonResponse
    {
        $member = $request->user()->member;
        if (!$member) return $this->error('Data anggota tidak ditemukan', 404);
        return $this->success($member->principalSaving);
    }

    // ============== ADMIN ==============

    public function deposit(DepositRequest $request): JsonResponse
    {
        $saving = $this->service->deposit(
            $request->member_id, (float) $request->amount, $request->description, $request->user()->id
        );
        return $this->success(['balance' => (float) $saving->balance], 'Tabungan berhasil disetor');
    }

    public function withdraw(WithdrawRequest $request): JsonResponse
    {
        $saving = $this->service->withdraw(
            $request->member_id, (float) $request->amount, $request->description, $request->user()->id
        );
        return $this->success(['balance' => (float) $saving->balance], 'Tabungan berhasil ditarik');
    }

    public function payMandatorySaving(PayMandatoryRequest $request): JsonResponse
    {
        $ms = $this->service->payMandatorySaving(
            $request->member_id, $request->period, (float) $request->amount, $request->user()->id
        );
        return $this->success(MandatorySavingResource::make($ms), 'Simpanan wajib berhasil dibayar');
    }

    public function allSavings(): JsonResponse
    {
        $savings = Saving::with('member')->orderByDesc('balance')->paginate(20);
        return $this->success($savings);
    }

    public function allMandatorySavings(Request $request): JsonResponse
    {
        $period = $request->query('period', now()->format('Y-m'));
        $items = MandatorySaving::with('member')->where('period', $period)->paginate(50);
        return $this->success([
            'period' => $period,
            'items' => MandatorySavingResource::collection($items)->response()->getData(true),
        ]);
    }
}
