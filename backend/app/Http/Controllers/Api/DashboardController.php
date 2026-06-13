<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Financing;
use App\Models\Installment;
use App\Models\MandatorySaving;
use App\Models\Member;
use App\Models\Saving;
use App\Models\SocialFund;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    use ApiResponse;

    public function admin(): JsonResponse
    {
        $monthlyStats = [];
        for ($i = 5; $i >= 0; $i--) {
            $date = now()->subMonths($i);
            $period = $date->format('Y-m');
            $monthlyStats[] = [
                'period'             => $period,
                'label'              => $date->translatedFormat('M Y'),
                'new_members'        => Member::whereYear('join_date', $date->year)->whereMonth('join_date', $date->month)->count(),
                'mandatory_savings'  => (float) MandatorySaving::where('period', $period)->where('status', 'paid')->sum('amount'),
                'installment_income' => (float) Installment::whereYear('paid_date', $date->year)->whereMonth('paid_date', $date->month)->where('status', 'paid')->sum('amount'),
            ];
        }

        return $this->success([
            'total_members'             => Member::active()->count(),
            'total_savings'             => (float) Saving::sum('balance'),
            'total_mandatory_savings'   => (float) MandatorySaving::where('status', 'paid')->sum('amount'),
            'total_principal_savings'   => (float) DB::table('principal_savings')->where('status', 'paid')->sum('amount'),
            'active_financing'          => Financing::where('status', 'approved')->count(),
            'total_financing_amount'    => (float) Financing::where('status', 'approved')->sum('total_price'),
            'total_financing_paid'      => (float) Financing::where('status', 'approved')->sum('total_paid'),
            'total_financing_remaining' => (float) Financing::where('status', 'approved')->sum('remaining'),
            'pending_financing'         => Financing::where('status', 'pending')->count(),
            'overdue_installments'      => Installment::where('status', 'overdue')->count(),
            'social_fund_in'            => (float) SocialFund::where('direction', 'in')->sum('amount'),
            'social_fund_out'           => (float) SocialFund::where('direction', 'out')->sum('amount'),
            'social_fund_balance'       => (float) (SocialFund::where('direction', 'in')->sum('amount') - SocialFund::where('direction', 'out')->sum('amount')),
            'monthly_stats'             => $monthlyStats,
        ]);
    }

    public function member(Request $request): JsonResponse
    {
        $member = $request->user()->member;
        if (!$member) return $this->error('Data anggota tidak ditemukan', 404);

        $saving = $member->savingAccount;
        $principalSaving = $member->principalSaving;
        $totalFinancing = (float) $member->financings()->where('status', 'approved')->sum('total_price');

        $activeInstallments = Installment::whereHas('financing', fn($q) => $q->where('member_id', $member->id)->where('status', 'approved'))
            ->whereIn('status', ['pending', 'partial', 'overdue'])
            ->count();

        $nextInstallment = Installment::whereHas('financing', fn($q) => $q->where('member_id', $member->id)->where('status', 'approved'))
            ->whereIn('status', ['pending', 'partial', 'overdue'])
            ->orderBy('due_date')
            ->first();

        $unpaidMandatory = $member->mandatorySavings()->whereIn('status', ['unpaid', 'overdue'])->count();

        // Recent transactions from saving account
        $recentTransactions = [];
        if ($saving) {
            $recentTransactions = $saving->transactions()
                ->orderByDesc('transaction_date')
                ->limit(5)
                ->get()
                ->map(fn($t) => [
                    'type'        => $t->type,
                    'description' => $t->description ?? ($t->type === 'deposit' ? 'Setoran' : 'Penarikan'),
                    'amount'      => (float) $t->amount,
                    'date'        => $t->transaction_date?->toDateTimeString() ?? $t->created_at->toDateTimeString(),
                ]);
        }

        return $this->success([
            'saving_balance'          => (float) ($saving?->balance ?? 0),
            'principal_saving'        => (float) ($principalSaving?->amount ?? 0),
            'total_financing'         => $totalFinancing,
            'active_installments'     => $activeInstallments,
            'next_installment_amount' => (float) ($nextInstallment?->amount ?? 0),
            'next_installment_due'    => $nextInstallment?->due_date?->format('Y-m-d'),
            'unpaid_mandatory'        => $unpaidMandatory,
            'unread_notifications'    => $request->user()->unreadNotifications()->count(),
            'recent_transactions'     => $recentTransactions,
        ]);
    }
}
