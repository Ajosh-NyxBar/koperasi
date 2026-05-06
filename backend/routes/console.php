<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// Schedule pekerjaan harian KBMT (overdue, generate mandatory, reminder)
Schedule::command('kbmt:daily')->dailyAt('06:00');
