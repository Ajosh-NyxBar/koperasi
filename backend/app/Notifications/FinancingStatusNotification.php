<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\Financing;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class FinancingStatusNotification extends Notification
{
    use Queueable;

    public function __construct(public Financing $financing, public string $status) {}

    public function via($notifiable): array { return ['database', FcmChannel::class]; }

    public function toDatabase($notifiable): array
    {
        $titles = [
            'approved' => 'Pembiayaan Disetujui',
            'rejected' => 'Pembiayaan Ditolak',
            'completed' => 'Pembiayaan Lunas',
        ];

        $messages = [
            'approved' => "Pengajuan pembiayaan {$this->financing->item_name} telah disetujui.",
            'rejected' => "Pengajuan pembiayaan {$this->financing->item_name} ditolak. Alasan: {$this->financing->reject_reason}",
            'completed' => "Selamat! Pembiayaan {$this->financing->item_name} telah lunas.",
        ];

        return [
            'category'        => 'financing_' . $this->status,
            'title'           => $titles[$this->status] ?? 'Update Pembiayaan',
            'message'         => $messages[$this->status] ?? '',
            'financing_id'    => $this->financing->id,
            'contract_number' => $this->financing->contract_number,
            'status'          => $this->status,
        ];
    }

    public function toFcm($notifiable): array
    {
        $dbData = $this->toDatabase($notifiable);
        return [
            'title' => $dbData['title'],
            'body'  => $dbData['message'],
            'data'  => [
                'type'         => 'financing_status',
                'financing_id' => (string) $this->financing->id,
                'status'       => $this->status,
            ],
        ];
    }
}
