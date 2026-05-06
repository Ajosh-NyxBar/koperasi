<?php

namespace App\Services;

use App\Models\MandatorySaving;
use App\Models\Saving;
use App\Models\SavingTransaction;
use App\Repositories\SavingRepository;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class SavingService
{
    public function __construct(private SavingRepository $repo) {}

    public function deposit(int $memberId, float $amount, ?string $description, ?int $createdBy = null): Saving
    {
        return DB::transaction(function () use ($memberId, $amount, $description, $createdBy) {
            $saving = $this->repo->firstOrCreateForMember($memberId);
            $saving->increment('balance', $amount);
            $saving->refresh();

            SavingTransaction::create([
                'saving_id'        => $saving->id,
                'type'             => 'deposit',
                'amount'           => $amount,
                'balance_after'    => $saving->balance,
                'reference'        => 'DEP-' . now()->format('YmdHis'),
                'description'      => $description ?? 'Setor tabungan',
                'transaction_date' => now()->toDateString(),
                'created_by'       => $createdBy,
            ]);

            return $saving;
        });
    }

    public function withdraw(int $memberId, float $amount, ?string $description, ?int $createdBy = null): Saving
    {
        return DB::transaction(function () use ($memberId, $amount, $description, $createdBy) {
            $saving = Saving::where('member_id', $memberId)->lockForUpdate()->first();
            if (!$saving || $saving->balance < $amount) {
                throw ValidationException::withMessages(['amount' => ['Saldo tidak mencukupi.']]);
            }

            $saving->decrement('balance', $amount);
            $saving->refresh();

            SavingTransaction::create([
                'saving_id'        => $saving->id,
                'type'             => 'withdrawal',
                'amount'           => $amount,
                'balance_after'    => $saving->balance,
                'reference'        => 'WD-' . now()->format('YmdHis'),
                'description'      => $description ?? 'Tarik tabungan',
                'transaction_date' => now()->toDateString(),
                'created_by'       => $createdBy,
            ]);

            return $saving;
        });
    }

    public function payMandatorySaving(int $memberId, string $period, float $amount, ?int $paidBy = null): MandatorySaving
    {
        return DB::transaction(function () use ($memberId, $period, $amount, $paidBy) {
            $existing = MandatorySaving::where('member_id', $memberId)->where('period', $period)->first();

            if ($existing && $existing->status === 'paid') {
                throw ValidationException::withMessages(['period' => ['Simpanan wajib periode ini sudah dibayar.']]);
            }

            $dueDate = \Carbon\Carbon::createFromFormat('Y-m', $period)->endOfMonth()->toDateString();

            if ($existing) {
                $existing->update([
                    'amount'    => $amount,
                    'paid_date' => now(),
                    'status'    => 'paid',
                    'paid_by'   => $paidBy,
                ]);
                return $existing->fresh();
            }

            return MandatorySaving::create([
                'member_id' => $memberId,
                'period'    => $period,
                'amount'    => $amount,
                'due_date'  => $dueDate,
                'paid_date' => now(),
                'status'    => 'paid',
                'paid_by'   => $paidBy,
            ]);
        });
    }

    public function generateMonthlyMandatory(int $memberId, string $period, float $amount = 50000): MandatorySaving
    {
        $dueDate = \Carbon\Carbon::createFromFormat('Y-m', $period)->endOfMonth()->toDateString();

        return MandatorySaving::firstOrCreate(
            ['member_id' => $memberId, 'period' => $period],
            ['amount' => $amount, 'due_date' => $dueDate, 'status' => 'unpaid']
        );
    }
}
