<?php

namespace App\Services;

use App\Models\Financing;
use App\Models\Installment;
use App\Models\MandatorySaving;
use App\Models\Member;
use App\Notifications\InstallmentDueNotification;
use App\Notifications\MandatorySavingDueNotification;

class NotificationService
{
    /**
     * Cek cicilan yang H-3 jatuh tempo & kirim notifikasi ke member terkait.
     * Juga tandai cicilan overdue.
     */
    public function dispatchInstallmentReminders(int $daysAhead = 3): int
    {
        $count = 0;
        $cutoff = now()->addDays($daysAhead)->toDateString();
        $today = now()->toDateString();

        // Tandai overdue
        Installment::whereIn('status', ['pending', 'partial'])
            ->whereDate('due_date', '<', $today)
            ->update(['status' => 'overdue']);

        // Reminder
        Installment::whereIn('status', ['pending', 'partial', 'overdue'])
            ->whereDate('due_date', '<=', $cutoff)
            ->with('financing.member.user')
            ->chunk(100, function ($items) use (&$count) {
                foreach ($items as $i) {
                    $user = $i->financing?->member?->user;
                    if ($user) {
                        $user->notify(new InstallmentDueNotification($i));
                        $count++;
                    }
                }
            });

        return $count;
    }

    /**
     * Generate simpanan wajib bulan berjalan untuk semua member aktif (jika belum ada),
     * lalu kirim reminder untuk yang masih unpaid setelah tanggal 15.
     */
    public function ensureCurrentMonthMandatory(float $defaultAmount = 50000): int
    {
        $period = now()->format('Y-m');
        $dueDate = now()->endOfMonth()->toDateString();
        $created = 0;

        Member::active()->chunk(100, function ($members) use ($period, $dueDate, $defaultAmount, &$created) {
            foreach ($members as $m) {
                $exists = MandatorySaving::where('member_id', $m->id)->where('period', $period)->exists();
                if (!$exists) {
                    MandatorySaving::create([
                        'member_id' => $m->id,
                        'period'    => $period,
                        'amount'    => $defaultAmount,
                        'due_date'  => $dueDate,
                        'status'    => 'unpaid',
                    ]);
                    $created++;
                }
            }
        });

        return $created;
    }

    public function dispatchMandatoryReminders(): int
    {
        $count = 0;
        MandatorySaving::unpaid()
            ->whereDate('due_date', '<=', now()->addDays(7)->toDateString())
            ->with('member.user')
            ->chunk(100, function ($items) use (&$count) {
                foreach ($items as $ms) {
                    $user = $ms->member?->user;
                    if ($user) {
                        $user->notify(new MandatorySavingDueNotification($ms));
                        $count++;
                    }
                }
            });

        return $count;
    }
}
