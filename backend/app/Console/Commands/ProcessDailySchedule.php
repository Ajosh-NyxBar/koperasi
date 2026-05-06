<?php

namespace App\Console\Commands;

use App\Services\FinancingService;
use App\Services\NotificationService;
use Illuminate\Console\Command;

class ProcessDailySchedule extends Command
{
    protected $signature = 'kbmt:daily';
    protected $description = 'Proses harian: tandai cicilan overdue, generate simpanan wajib bulanan, kirim reminder.';

    public function handle(FinancingService $fin, NotificationService $notif): int
    {
        $overdue = $fin->markOverdueInstallments();
        $this->info("Cicilan ditandai overdue: {$overdue}");

        $created = $notif->ensureCurrentMonthMandatory();
        $this->info("Simpanan wajib bulanan dibuat: {$created}");

        $instReminders = $notif->dispatchInstallmentReminders();
        $this->info("Reminder cicilan dikirim: {$instReminders}");

        $msReminders = $notif->dispatchMandatoryReminders();
        $this->info("Reminder simpanan wajib dikirim: {$msReminders}");

        return self::SUCCESS;
    }
}
