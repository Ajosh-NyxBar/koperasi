<?php

namespace App\Services;

use App\Exports\FinancingExport;
use App\Exports\MemberExport;
use App\Exports\SavingExport;
use App\Exports\SocialFundExport;
use App\Models\Financing;
use App\Models\Member;
use App\Models\SavingTransaction;
use App\Models\SocialFund;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Http\Response;
use Maatwebsite\Excel\Facades\Excel;
use Symfony\Component\HttpFoundation\BinaryFileResponse;

class ReportService
{
    // ============== DATA QUERIES ==============

    public function membersData(?string $status = null): \Illuminate\Database\Eloquent\Collection
    {
        return Member::with(['user', 'savingAccount', 'principalSaving'])
            ->when($status, fn($q) => $q->where('status', $status))
            ->orderBy('full_name')
            ->get();
    }

    public function savingsData(?string $from = null, ?string $to = null): \Illuminate\Database\Eloquent\Collection
    {
        return SavingTransaction::with(['savingAccount.member'])
            ->when($from, fn($q) => $q->whereDate('transaction_date', '>=', $from))
            ->when($to, fn($q) => $q->whereDate('transaction_date', '<=', $to))
            ->orderByDesc('transaction_date')
            ->get();
    }

    public function financingsData(?string $status = null, ?string $from = null, ?string $to = null): \Illuminate\Database\Eloquent\Collection
    {
        return Financing::with(['member', 'product'])
            ->when($status, fn($q) => $q->where('status', $status))
            ->when($from, fn($q) => $q->whereDate('application_date', '>=', $from))
            ->when($to, fn($q) => $q->whereDate('application_date', '<=', $to))
            ->orderByDesc('application_date')
            ->get();
    }

    public function socialFundsData(?string $direction = null, ?string $from = null, ?string $to = null): \Illuminate\Database\Eloquent\Collection
    {
        return SocialFund::with('member')
            ->when($direction, fn($q) => $q->where('direction', $direction))
            ->when($from, fn($q) => $q->whereDate('transaction_date', '>=', $from))
            ->when($to, fn($q) => $q->whereDate('transaction_date', '<=', $to))
            ->orderByDesc('transaction_date')
            ->get();
    }

    // ============== PDF EXPORTS ==============

    public function membersPdf(?string $status = null): Response
    {
        $data = $this->membersData($status);
        $pdf = Pdf::loadView('reports.members', ['members' => $data, 'status' => $status]);
        return $pdf->download('laporan-anggota-' . now()->format('Ymd-His') . '.pdf');
    }

    public function savingsPdf(?string $from, ?string $to): Response
    {
        $data = $this->savingsData($from, $to);
        $pdf = Pdf::loadView('reports.savings', ['transactions' => $data, 'from' => $from, 'to' => $to]);
        return $pdf->download('laporan-tabungan-' . now()->format('Ymd-His') . '.pdf');
    }

    public function financingsPdf(?string $status, ?string $from, ?string $to): Response
    {
        $data = $this->financingsData($status, $from, $to);
        $pdf = Pdf::loadView('reports.financings', ['financings' => $data, 'status' => $status, 'from' => $from, 'to' => $to]);
        return $pdf->download('laporan-pembiayaan-' . now()->format('Ymd-His') . '.pdf');
    }

    public function socialFundsPdf(?string $direction, ?string $from, ?string $to): Response
    {
        $data = $this->socialFundsData($direction, $from, $to);
        $pdf = Pdf::loadView('reports.social-funds', ['funds' => $data, 'direction' => $direction, 'from' => $from, 'to' => $to]);
        return $pdf->download('laporan-dana-sosial-' . now()->format('Ymd-His') . '.pdf');
    }

    // ============== EXCEL EXPORTS ==============

    public function membersExcel(?string $status = null): BinaryFileResponse
    {
        return Excel::download(new MemberExport($this->membersData($status)), 'laporan-anggota-' . now()->format('Ymd-His') . '.xlsx');
    }

    public function savingsExcel(?string $from, ?string $to): BinaryFileResponse
    {
        return Excel::download(new SavingExport($this->savingsData($from, $to)), 'laporan-tabungan-' . now()->format('Ymd-His') . '.xlsx');
    }

    public function financingsExcel(?string $status, ?string $from, ?string $to): BinaryFileResponse
    {
        return Excel::download(new FinancingExport($this->financingsData($status, $from, $to)), 'laporan-pembiayaan-' . now()->format('Ymd-His') . '.xlsx');
    }

    public function socialFundsExcel(?string $direction, ?string $from, ?string $to): BinaryFileResponse
    {
        return Excel::download(new SocialFundExport($this->socialFundsData($direction, $from, $to)), 'laporan-dana-sosial-' . now()->format('Ymd-His') . '.xlsx');
    }
}
