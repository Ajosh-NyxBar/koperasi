@extends('reports.layout')
@section('title', 'Laporan Dana Sosial')
@section('subtitle', 'Laporan Kas Dana Sosial')
@section('content')
@php
    $totIn = $funds->where('direction', 'in')->sum('amount');
    $totOut = $funds->where('direction', 'out')->sum('amount');
@endphp
<div class="summary">
    Pemasukan: <strong>Rp {{ number_format($totIn, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Pengeluaran: <strong>Rp {{ number_format($totOut, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Saldo: <strong>Rp {{ number_format($totIn - $totOut, 0, ',', '.') }}</strong>
</div>
<table>
    <thead>
    <tr>
        <th>Tanggal</th><th>Tipe</th><th>Arah</th>
        <th class="text-right">Jumlah</th><th>Anggota</th><th>Keterangan</th>
    </tr>
    </thead>
    <tbody>
    @foreach($funds as $s)
        <tr>
            <td>{{ optional($s->transaction_date)->format('d/m/Y') }}</td>
            <td>{{ ucfirst(str_replace('_', ' ', $s->type)) }}</td>
            <td>{{ $s->direction === 'in' ? 'Masuk' : 'Keluar' }}</td>
            <td class="text-right">Rp {{ number_format($s->amount, 0, ',', '.') }}</td>
            <td>{{ optional($s->member)->full_name ?? '-' }}</td>
            <td>{{ $s->description }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
@endsection
