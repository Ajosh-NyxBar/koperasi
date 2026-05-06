<?php

namespace App\Services;

use App\Models\Financing;
use App\Models\Installment;
use App\Models\InstallmentPayment;
use App\Notifications\FinancingStatusNotification;
use App\Repositories\FinancingRepository;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class FinancingService
{
    public function __construct(private FinancingRepository $repo) {}

    public function simulate(float $basePrice, float $marginPct, int $tenor): array
    {
        $marginAmount = $basePrice * $marginPct / 100;
        $totalPrice = $basePrice + $marginAmount;
        $monthlyInstallment = (float) ceil($totalPrice / $tenor);

        return [
            'base_price'          => $basePrice,
            'margin_percentage'   => $marginPct,
            'margin_amount'       => round($marginAmount, 2),
            'total_price'         => round($totalPrice, 2),
            'tenor'               => $tenor,
            'monthly_installment' => $monthlyInstallment,
            'schedule'            => $this->buildSchedulePreview($monthlyInstallment, $tenor),
        ];
    }

    private function buildSchedulePreview(float $monthly, int $tenor): array
    {
        $rows = [];
        for ($i = 1; $i <= $tenor; $i++) {
            $rows[] = [
                'installment_number' => $i,
                'amount'             => $monthly,
                'due_date'           => now()->addMonths($i)->toDateString(),
            ];
        }
        return $rows;
    }

    public function createApplication(array $data): Financing
    {
        $sim = $this->simulate(
            (float) $data['base_price'],
            (float) $data['margin_percentage'],
            (int) $data['tenor']
        );

        return Financing::create([
            'contract_number'     => $this->repo->generateContractNumber(),
            'member_id'           => $data['member_id'],
            'product_id'          => $data['product_id'] ?? null,
            'item_name'           => $data['item_name'],
            'base_price'          => $sim['base_price'],
            'margin_percentage'   => $sim['margin_percentage'],
            'margin_amount'       => $sim['margin_amount'],
            'total_price'         => $sim['total_price'],
            'tenor'               => $sim['tenor'],
            'monthly_installment' => $sim['monthly_installment'],
            'total_paid'          => 0,
            'remaining'           => $sim['total_price'],
            'penalty_per_day'     => $data['penalty_per_day'] ?? 5000,
            'status'              => 'pending',
            'application_date'    => now(),
            'notes'               => $data['notes'] ?? null,
        ]);
    }

    public function approve(Financing $financing, int $approvedBy): Financing
    {
        if ($financing->status !== 'pending') {
            throw ValidationException::withMessages(['status' => ['Pembiayaan tidak dalam status pending.']]);
        }

        return DB::transaction(function () use ($financing, $approvedBy) {
            $financing->update([
                'status'        => 'approved',
                'approved_date' => now(),
                'approved_by'   => $approvedBy,
            ]);

            $base = Carbon::parse($financing->approved_date);
            for ($i = 1; $i <= $financing->tenor; $i++) {
                Installment::create([
                    'financing_id'       => $financing->id,
                    'installment_number' => $i,
                    'amount'             => $financing->monthly_installment,
                    'due_date'           => $base->copy()->addMonths($i)->toDateString(),
                    'status'             => 'pending',
                ]);
            }

            $financing->member->user?->notify(new FinancingStatusNotification($financing, 'approved'));
            return $financing->load('installments');
        });
    }

    public function reject(Financing $financing, string $reason, int $rejectedBy): Financing
    {
        if ($financing->status !== 'pending') {
            throw ValidationException::withMessages(['status' => ['Pembiayaan tidak dalam status pending.']]);
        }

        $financing->update([
            'status'        => 'rejected',
            'reject_reason' => $reason,
            'approved_by'   => $rejectedBy,
            'approved_date' => now(),
        ]);

        $financing->member->user?->notify(new FinancingStatusNotification($financing, 'rejected'));
        return $financing;
    }

    public function payInstallment(Financing $financing, ?int $installmentId, float $amount, float $penaltyPaid, string $method, ?string $notes, int $receivedBy): array
    {
        if ($financing->status !== 'approved') {
            throw ValidationException::withMessages(['status' => ['Pembiayaan harus berstatus approved.']]);
        }

        return DB::transaction(function () use ($financing, $installmentId, $amount, $penaltyPaid, $method, $notes, $receivedBy) {
            $installment = $installmentId
                ? $financing->installments()->whereIn('status', ['pending', 'partial', 'overdue'])->where('id', $installmentId)->firstOrFail()
                : $financing->installments()->whereIn('status', ['pending', 'partial', 'overdue'])->orderBy('installment_number')->first();

            if (!$installment) {
                throw ValidationException::withMessages(['amount' => ['Tidak ada cicilan pending.']]);
            }

            $newPaid = (float) $installment->paid_amount + $amount;
            $status = $newPaid >= (float) $installment->amount ? 'paid' : 'partial';

            $installment->update([
                'paid_amount'    => $newPaid,
                'penalty_amount' => (float) $installment->penalty_amount + $penaltyPaid,
                'paid_date'      => $status === 'paid' ? now() : $installment->paid_date,
                'status'         => $status,
            ]);

            $payment = InstallmentPayment::create([
                'installment_id' => $installment->id,
                'financing_id'   => $financing->id,
                'receipt_number' => 'RCP-' . now()->format('YmdHis') . '-' . $installment->id,
                'amount'         => $amount,
                'penalty_paid'   => $penaltyPaid,
                'payment_date'   => now()->toDateString(),
                'method'         => $method,
                'notes'          => $notes,
                'received_by'    => $receivedBy,
            ]);

            $financing->increment('total_paid', $amount);
            $financing->decrement('remaining', $amount);
            $financing->refresh();

            if ($financing->remaining <= 0) {
                $financing->update(['status' => 'completed', 'completed_date' => now()]);
                $financing->member->user?->notify(new FinancingStatusNotification($financing, 'completed'));
            }

            return ['financing' => $financing->fresh()->load('installments'), 'payment' => $payment];
        });
    }

    public function markOverdueInstallments(): int
    {
        $now = now()->toDateString();
        return Installment::whereIn('status', ['pending', 'partial'])
            ->whereDate('due_date', '<', $now)
            ->update(['status' => 'overdue']);
    }
}
