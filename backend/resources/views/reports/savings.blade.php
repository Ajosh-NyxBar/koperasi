@extends('reports.layout')
@section('title', 'Laporan Tabungan')
@section('subtitle', 'Laporan Transaksi Tabungan' . ($from || $to ? ' - ' . ($from ?? '...') . ' s/d ' . ($to ?? '...') : ''))
@section('content')
@php
    $totalIn = $transactions->where('type', 'deposit')->sum('amount');
    $totalOut = $transactions->where('type', 'withdrawal')->sum('amount');
@endphp
<div class="summary">
    Total Setoran: <strong>Rp {{ number_format($totalIn, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Total Penarikan: <strong>Rp {{ number_format($totalOut, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Net: <strong>Rp {{ number_format($totalIn - $totalOut, 0, ',', '.') }}</strong>
</div>
<table>
    <thead>
    <tr>
        <th>Tanggal</th><th>Referensi</th><th>Anggota</th><th>Tipe</th>
        <th class="text-right">Jumlah</th><th class="text-right">Saldo Setelah</th><th>Keterangan</th>
    </tr>
    </thead>
    <tbody>
    @foreach($transactions as $t)
        <tr>
            <td>{{ optional($t->transaction_date)->format('d/m/Y') }}</td>
            <td>{{ $t->reference }}</td>
            <td>{{ optional($t->savingAccount?->member)->full_name }}</td>
            <td>{{ $t->type === 'deposit' ? 'Setor' : 'Tarik' }}</td>
            <td class="text-right">Rp {{ number_format($t->amount, 0, ',', '.') }}</td>
            <td class="text-right">Rp {{ number_format($t->balance_after, 0, ',', '.') }}</td>
            <td>{{ $t->description }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
@endsection
