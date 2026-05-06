<?php

namespace App\Exports;

use Illuminate\Support\Collection;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithStyles;
use PhpOffice\PhpSpreadsheet\Worksheet\Worksheet;

class MemberExport implements FromCollection, WithHeadings, WithStyles
{
    public function __construct(private $data) {}

    public function collection(): Collection
    {
        return collect($this->data)->map(function ($m) {
            return [
                'kode'           => $m->member_code,
                'nama'           => $m->full_name,
                'nik'            => $m->nik,
                'email'          => $m->user?->email,
                'telepon'        => $m->phone,
                'jenis_kelamin'  => $m->gender === 'L' ? 'Laki-laki' : 'Perempuan',
                'pekerjaan'      => $m->occupation,
                'penghasilan'    => $m->monthly_income,
                'saldo_tabungan' => optional($m->savingAccount)->balance ?? 0,
                'simpanan_pokok' => optional($m->principalSaving)->amount ?? 0,
                'tgl_bergabung'  => optional($m->join_date)->toDateString(),
                'status'         => $m->status,
            ];
        });
    }

    public function headings(): array
    {
        return ['Kode', 'Nama', 'NIK', 'Email', 'Telepon', 'JK', 'Pekerjaan', 'Penghasilan', 'Saldo Tab.', 'S. Pokok', 'Tgl Bergabung', 'Status'];
    }

    public function styles(Worksheet $sheet): array
    {
        return [1 => ['font' => ['bold' => true]]];
    }
}
