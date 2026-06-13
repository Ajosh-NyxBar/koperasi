<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\MandatorySaving;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class MandatorySavingDueNotification extends Notification
{
    use Queueable;

    public function __construct(public MandatorySaving $mandatorySaving) {}

    public function via($notifiable): array { return ['database', FcmChannel::class]; }

    public function toDatabase($notifiable): array
    {
        return [
            'category'  => 'mandatory_saving_due',
            'title'     => 'Simpanan Wajib Belum Dibayar',
            'message'   => "Simpanan wajib periode {$this->mandatorySaving->period} belum dibayar.",
            'period'    => $this->mandatorySaving->period,
            'amount'    => (float) $this->mandatorySaving->amount,
            'due_date'  => $this->mandatorySaving->due_date->toDateString(),
            'status'    => $this->mandatorySaving->status,
        ];
    }

    public function toFcm($notifiable): array
    {
        $dbData = $this->toDatabase($notifiable);
        return [
            'title' => $dbData['title'],
            'body'  => $dbData['message'],
            'data'  => [
                'type'   => 'mandatory_saving_due',
                'period' => $this->mandatorySaving->period,
            ],
        ];
    }
}
