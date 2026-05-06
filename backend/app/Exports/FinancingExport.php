<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class FinancingExport implements FromCollection, WithHeadings, WithStyles
{
    public function __construct(private $data) {}

    public function collection(): Collection
    {
        return collect($this->data)->map(function ($f) {
            return [
                'kontrak'       => $f->contract_number,
                'tgl_pengajuan' => optional($f->application_date)->toDateString(),
                'anggota'       => optional($f->member)->full_name,
                'barang'        => $f->item_name,
                'harga_dasar'   => $f->base_price,
                'margin_pct'    => $f->margin_percentage,
                'total'         => $f->total_price,
                'tenor'         => $f->tenor,
                'angsuran'      => $f->monthly_installment,
                'terbayar'      => $f->total_paid,
                'sisa'          => $f->remaining,
                'status'        => $f->status,
            ];
        });
    }

    public function headings(): array
    {
        return ['Kontrak', 'Tgl Pengajuan', 'Anggota', 'Barang', 'Harga Dasar', 'Margin %', 'Total', 'Tenor', 'Angsuran', 'Terbayar', 'Sisa', 'Status'];
    }

    public function styles(Worksheet $sheet): array { return [1 => ['font' => ['bold' => true]]]; }
}
