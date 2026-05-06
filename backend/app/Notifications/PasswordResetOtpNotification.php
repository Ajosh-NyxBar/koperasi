<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetOtpNotification extends Notification
{
    use Queueable;

    public function __construct(public string $otp, public string $token) {}

    public function via($notifiable): array { return ['mail']; }

    public function toMail($notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Reset Password KBMT - Kode OTP')
            ->greeting('Halo ' . ($notifiable->name ?? '') . ',')
            ->line('Anda telah meminta reset password.')
            ->line('Gunakan kode OTP berikut (berlaku 10 menit):')
            ->line('**' . $this->otp . '**')
            ->line('Atau gunakan token: ' . $this->token)
            ->line('Jika Anda tidak meminta reset password, abaikan email ini.');
    }
}
