<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class SavingExport implements FromCollection, WithHeadings, WithStyles
{
    public function __construct(private $data) {}

    public function collection(): Collection
    {
        return collect($this->data)->map(function ($t) {
            return [
                'tanggal'       => optional($t->transaction_date)->toDateString(),
                'referensi'     => $t->reference,
                'anggota_kode'  => optional($t->savingAccount?->member)->member_code,
                'anggota_nama'  => optional($t->savingAccount?->member)->full_name,
                'tipe'          => $t->type,
                'jumlah'        => $t->amount,
                'saldo_setelah' => $t->balance_after,
                'keterangan'    => $t->description,
            ];
        });
    }

    public function headings(): array
    {
        return ['Tanggal', 'Referensi', 'Kode', 'Anggota', 'Tipe', 'Jumlah', 'Saldo Setelah', 'Keterangan'];
    }

    public function styles(Worksheet $sheet): array { return [1 => ['font' => ['bold' => true]]]; }
}
