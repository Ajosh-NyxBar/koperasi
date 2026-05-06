<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ReportService;
use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function __construct(private ReportService $reports) {}

    public function members(Request $request)
    {
        $format = $request->query('format', 'pdf');
        $status = $request->query('status');
        return $format === 'excel'
            ? $this->reports->membersExcel($status)
            : $this->reports->membersPdf($status);
    }

    public function savings(Request $request)
    {
        $format = $request->query('format', 'pdf');
        return $format === 'excel'
            ? $this->reports->savingsExcel($request->query('from'), $request->query('to'))
            : $this->reports->savingsPdf($request->query('from'), $request->query('to'));
    }

    public function financings(Request $request)
    {
        $format = $request->query('format', 'pdf');
        return $format === 'excel'
            ? $this->reports->financingsExcel($request->query('status'), $request->query('from'), $request->query('to'))
            : $this->reports->financingsPdf($request->query('status'), $request->query('from'), $request->query('to'));
    }

    public function socialFunds(Request $request)
    {
        $format = $request->query('format', 'pdf');
        return $format === 'excel'
            ? $this->reports->socialFundsExcel($request->query('direction'), $request->query('from'), $request->query('to'))
            : $this->reports->socialFundsPdf($request->query('direction'), $request->query('from'), $request->query('to'));
    }
}
