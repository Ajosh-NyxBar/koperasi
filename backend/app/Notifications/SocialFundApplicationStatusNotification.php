<?php

namespace App\Notifications;

use App\Channels\FcmChannel;
use App\Models\SocialFundApplication;
use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;

class SocialFundApplicationStatusNotification extends Notification
{
    use Queueable;

    public function __construct(public SocialFundApplication $application, public string $status) {}

    public function via($notifiable): array { return ['database', FcmChannel::class]; }

    public function toDatabase($notifiable): array
    {
        $titles = [
            'approved' => 'Pengajuan Bantuan Disetujui',
            'rejected' => 'Pengajuan Bantuan Ditolak',
            'disbursed' => 'Bantuan Telah Dicairkan',
        ];

        return [
            'category'           => 'social_fund_' . $this->status,
            'title'              => $titles[$this->status] ?? 'Update Pengajuan Bantuan',
            'message'            => "Pengajuan {$this->application->application_number} berstatus {$this->status}.",
            'application_id'     => $this->application->id,
            'application_number' => $this->application->application_number,
            'status'             => $this->status,
        ];
    }

    public function toFcm($notifiable): array
    {
        $dbData = $this->toDatabase($notifiable);
        return [
            'title' => $dbData['title'],
            'body'  => $dbData['message'],
            'data'  => [
                'type'           => 'social_fund_status',
                'application_id' => (string) $this->application->id,
                'status'         => $this->status,
            ],
        ];
    }
}
