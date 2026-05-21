<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Installment;
use App\Models\PenaltySetting;
use App\Models\PenaltyWaiver;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class PenaltyController extends Controller
{
    use ApiResponse;

    // ==================== PENALTY SETTINGS ====================

    public function settings(): JsonResponse
    {
        $settings = PenaltySetting::orderByDesc('is_default')->orderBy('name')->get();
        return $this->success($settings);
    }

    public function storeSetting(Request $request): JsonResponse
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'penalty_per_day' => ['required', 'numeric', 'min:0'],
            'grace_period_days' => ['required', 'integer', 'min:0'],
            'max_penalty_percentage' => ['required', 'numeric', 'min:0', 'max:100'],
            'is_default' => ['boolean'],
        ]);

        return DB::transaction(function () use ($data) {
            // Jika set sebagai default, unset yang lain
            if (!empty($data['is_default'])) {
                PenaltySetting::where('is_default', true)->update(['is_default' => false]);
            }

            $setting = PenaltySetting::create($data);
            return $this->created($setting, 'Pengaturan denda berhasil dibuat');
        });
    }

    public function updateSetting(Request $request, PenaltySetting $setting): JsonResponse
    {
        $data = $request->validate([
            'name' => ['sometimes', 'string', 'max:100'],
            'penalty_per_day' => ['sometimes', 'numeric', 'min:0'],
            'grace_period_days' => ['sometimes', 'integer', 'min:0'],
            'max_penalty_percentage' => ['sometimes', 'numeric', 'min:0', 'max:100'],
            'is_default' => ['boolean'],
            'is_active' => ['boolean'],
        ]);

        return DB::transaction(function () use ($data, $setting) {
            if (!empty($data['is_default'])) {
                PenaltySetting::where('is_default', true)->where('id', '!=', $setting->id)->update(['is_default' => false]);
            }

            $setting->update($data);
            return $this->success($setting, 'Pengaturan denda berhasil diperbarui');
        });
    }

    public function deleteSetting(PenaltySetting $setting): JsonResponse
    {
        if ($setting->is_default) {
            return $this->error('Tidak bisa menghapus pengaturan default', 422);
        }

        $setting->delete();
        return $this->success(null, 'Pengaturan denda berhasil dihapus');
    }

    // ==================== PENALTY WAIVER (KERINGANAN) ====================

    public function waive(Request $request, Installment $installment): JsonResponse
    {
        $data = $request->validate([
            'waived_amount' => ['required', 'numeric', 'min:1'],
            'reason' => ['required', 'string', 'min:5', 'max:500'],
        ]);

        $currentPenalty = $installment->calculatePenalty();

        if ($currentPenalty <= 0) {
            return $this->error('Cicilan ini tidak memiliki denda aktif', 422);
        }

        if ($data['waived_amount'] > $currentPenalty) {
            return $this->error('Jumlah keringanan tidak boleh melebihi denda saat ini (Rp ' . number_format($currentPenalty, 0, ',', '.') . ')', 422);
        }

        return DB::transaction(function () use ($data, $installment, $currentPenalty, $request) {
            $finalPenalty = $currentPenalty - $data['waived_amount'];

            // Catat waiver
            $waiver = PenaltyWaiver::create([
                'installment_id' => $installment->id,
                'financing_id' => $installment->financing_id,
                'original_penalty' => $currentPenalty,
                'waived_amount' => $data['waived_amount'],
                'final_penalty' => $finalPenalty,
                'reason' => $data['reason'],
                'waived_by' => $request->user()->id,
            ]);

            // Update waived_penalty di installment
            $installment->increment('waived_penalty', $data['waived_amount']);

            return $this->success([
                'waiver' => $waiver,
                'installment' => [
                    'id' => $installment->id,
                    'installment_number' => $installment->installment_number,
                    'current_penalty' => $installment->fresh()->calculatePenalty(),
                    'waived_penalty' => (float) $installment->fresh()->waived_penalty,
                ],
            ], 'Keringanan denda berhasil diberikan');
        });
    }

    // ==================== OVERVIEW DENDA ====================

    public function overview(): JsonResponse
    {
        $overdueInstallments = Installment::whereIn('status', ['overdue', 'partial'])
            ->whereDate('due_date', '<', now())
            ->with(['financing.member'])
            ->get();

        $totalPenalty = 0;
        $totalWaived = 0;
        $totalPaid = 0;
        $items = [];

        foreach ($overdueInstallments as $inst) {
            $currentPenalty = $inst->calculatePenalty();
            $totalPenalty += $currentPenalty;
            $totalWaived += (float) $inst->waived_penalty;
            $totalPaid += (float) $inst->penalty_amount;

            if ($currentPenalty > 0) {
                $items[] = [
                    'installment_id' => $inst->id,
                    'financing_id' => $inst->financing_id,
                    'contract_number' => $inst->financing->contract_number,
                    'member_name' => $inst->financing->member->full_name ?? '-',
                    'installment_number' => $inst->installment_number,
                    'due_date' => $inst->due_date->toDateString(),
                    'days_overdue' => $inst->due_date->diffInDays(now()),
                    'installment_amount' => (float) $inst->amount,
                    'current_penalty' => $currentPenalty,
                    'outstanding_penalty' => $inst->getOutstandingPenalty(),
                    'penalty_paid' => (float) $inst->penalty_amount,
                    'waived_penalty' => (float) $inst->waived_penalty,
                ];
            }
        }

        return $this->success([
            'summary' => [
                'total_current_penalty' => $totalPenalty,
                'total_waived' => $totalWaived,
                'total_paid' => $totalPaid,
                'overdue_count' => count($items),
            ],
            'items' => $items,
            'settings' => PenaltySetting::getDefault(),
        ]);
    }

    public function waiverHistory(Request $request): JsonResponse
    {
        $query = PenaltyWaiver::with(['installment', 'financing.member', 'waivedByUser'])
            ->orderByDesc('created_at');

        if ($request->filled('financing_id')) {
            $query->where('financing_id', $request->financing_id);
        }

        $waivers = $query->paginate(20);

        return $this->success($waivers);
    }
}
