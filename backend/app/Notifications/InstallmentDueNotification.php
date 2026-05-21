<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Installment;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class InstallmentDueNotification extends Notification
{
    use Queueable;

    public function __construct(public Installment $installment) {}

    public function via($notifiable): array { return ['database', FcmChannel::class]; }

    public function toDatabase($notifiable): array
    {
        $this->installment->loadMissing('financing');
        return [
            'category'           => 'installment_due',
            'title'              => 'Cicilan Jatuh Tempo',
            'message'            => "Cicilan ke-{$this->installment->installment_number} kontrak {$this->installment->financing->contract_number} jatuh tempo {$this->installment->due_date->toDateString()}.",
            'installment_id'     => $this->installment->id,
            'financing_id'       => $this->installment->financing_id,
            'amount'             => (float) $this->installment->amount,
            'due_date'           => $this->installment->due_date->toDateString(),
            'is_overdue'         => $this->installment->isOverdue(),
        ];
    }

    public function toFcm($notifiable): array
    {
        $dbData = $this->toDatabase($notifiable);
        return [
            'title' => $dbData['title'],
            'body'  => $dbData['message'],
            'data'  => [
                'type'           => 'installment_due',
                'financing_id'   => (string) $this->installment->financing_id,
                'installment_id' => (string) $this->installment->id,
            ],
        ];
    }
}
