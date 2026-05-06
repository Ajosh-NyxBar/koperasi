<?php

namespace App\Services;

use App\Models\SocialFund;
use App\Models\SocialFundApplication;
use App\Notifications\SocialFundApplicationStatusNotification;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class SocialFundService
{
    public function recordTransaction(array $data, int $createdBy): SocialFund
    {
        return SocialFund::create([
            'member_id'        => $data['member_id'] ?? null,
            'application_id'   => $data['application_id'] ?? null,
            'type'             => $data['type'],
            'direction'        => $data['direction'],
            'amount'           => $data['amount'],
            'description'      => $data['description'] ?? null,
            'transaction_date' => now()->toDateString(),
            'created_by'       => $createdBy,
        ]);
    }

    public function applyForAid(int $memberId, array $data, ?UploadedFile $attachment = null): SocialFundApplication
    {
        $next = (SocialFundApplication::withTrashed()->max('id') ?? 0) + 1;
        $number = 'APP-' . now()->format('Ym') . '-' . str_pad((string) $next, 4, '0', STR_PAD_LEFT);

        $payload = [
            'application_number' => $number,
            'member_id'          => $memberId,
            'type'               => $data['type'],
            'requested_amount'   => $data['requested_amount'],
            'reason'             => $data['reason'],
            'status'             => 'pending',
            'application_date'   => now()->toDateString(),
        ];

        if ($attachment) {
            $payload['attachment'] = $attachment->store('social-funds', 'public');
        }

        return SocialFundApplication::create($payload);
    }

    public function decide(SocialFundApplication $app, string $decision, ?float $approvedAmount, ?string $notes, int $deciderId): SocialFundApplication
    {
        if ($app->status !== 'pending') {
            throw ValidationException::withMessages(['status' => ['Pengajuan sudah diputuskan.']]);
        }

        return DB::transaction(function () use ($app, $decision, $approvedAmount, $notes, $deciderId) {
            $app->update([
                'status'          => $decision,
                'approved_amount' => $decision === 'approved' ? $approvedAmount : null,
                'admin_notes'     => $notes,
                'decided_date'    => now()->toDateString(),
                'decided_by'      => $deciderId,
            ]);

            if ($decision === 'approved' && $approvedAmount > 0) {
                // Catat keluaran kas dana sosial
                SocialFund::create([
                    'member_id'        => $app->member_id,
                    'application_id'   => $app->id,
                    'type'             => $app->type,
                    'direction'        => 'out',
                    'amount'           => $approvedAmount,
                    'description'      => "Pencairan {$app->application_number}",
                    'transaction_date' => now()->toDateString(),
                    'created_by'       => $deciderId,
                ]);
                $app->update(['status' => 'disbursed']);
            }

            $app->member->user?->notify(new SocialFundApplicationStatusNotification($app, $app->status));
            return $app->fresh();
        });
    }
}
