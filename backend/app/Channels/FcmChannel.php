<?php

namespace App\Channels;

use App\Services\FcmService;
use Illuminate\Notifications\Notification;

class FcmChannel
{
    public function __construct(private FcmService $fcm) {}

    /**
     * Send the given notification via FCM.
     */
    public function send(object $notifiable, Notification $notification): void
    {
        // Notification harus punya method toFcm()
        if (!method_exists($notification, 'toFcm')) {
            // Fallback: gunakan toDatabase() untuk title dan body
            if (method_exists($notification, 'toDatabase')) {
                $data = $notification->toDatabase($notifiable);
                $title = $data['title'] ?? 'KBMT';
                $body = $data['message'] ?? '';
                $payload = $data;
            } else {
                return;
            }
        } else {
            $fcmData = $notification->toFcm($notifiable);
            $title = $fcmData['title'] ?? 'KBMT';
            $body = $fcmData['body'] ?? '';
            $payload = $fcmData['data'] ?? [];
        }

        $userId = $notifiable->id ?? null;
        if (!$userId) return;

        $this->fcm->sendToUser($userId, $title, $body, $payload);
    }
}
