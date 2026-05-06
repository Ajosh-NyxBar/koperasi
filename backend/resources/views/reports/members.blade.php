@extends('reports.layout')
@section('title', 'Laporan Anggota')
@section('subtitle', 'Laporan Data Anggota' . ($status ? ' - Status: ' . strtoupper($status) : ''))
@section('content')
<div class="summary">Total: <strong>{{ $members->count() }}</strong> anggota</div>
<table>
    <thead>
    <tr>
        <th>#</th><th>Kode</th><th>Nama</th><th>NIK</th><th>Telp</th><th>JK</th>
        <th class="text-right">Tabungan</th><th>Status</th><th>Bergabung</th>
    </tr>
    </thead>
    <tbody>
    @foreach($members as $i => $m)
        <tr>
            <td>{{ $i + 1 }}</td>
            <td>{{ $m->member_code }}</td>
            <td>{{ $m->full_name }}</td>
            <td>{{ $m->nik }}</td>
            <td>{{ $m->phone ?? '-' }}</td>
            <td>{{ $m->gender }}</td>
            <td class="text-right">Rp {{ number_format(optional($m->savingAccount)->balance ?? 0, 0, ',', '.') }}</td>
            <td>{{ ucfirst($m->status) }}</td>
            <td>{{ optional($m->join_date)->format('d/m/Y') }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
@endsection
