<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class SocialFundExport implements FromCollection, WithHeadings, WithStyles
{
    public function __construct(private $data) {}

    public function collection(): Collection
    {
        return collect($this->data)->map(function ($s) {
            return [
                'tanggal'    => optional($s->transaction_date)->toDateString(),
                'tipe'       => $s->type,
                'arah'       => $s->direction,
                'jumlah'     => $s->amount,
                'anggota'    => optional($s->member)->full_name,
                'keterangan' => $s->description,
            ];
        });
    }

    public function headings(): array
    {
        return ['Tanggal', 'Tipe', 'Arah', 'Jumlah', 'Anggota', 'Keterangan'];
    }

    public function styles(Worksheet $sheet): array { return [1 => ['font' => ['bold' => true]]]; }
}
