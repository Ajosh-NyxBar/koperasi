@extends('reports.layout')
@section('title', 'Laporan Pembiayaan')
@section('subtitle', 'Laporan Pembiayaan' . ($status ? ' - Status: ' . strtoupper($status) : ''))
@section('content')
@php
    $totPokok = $financings->sum('total_price');
    $totBayar = $financings->sum('total_paid');
    $totSisa = $financings->sum('remaining');
@endphp
<div class="summary">
    Total Pokok+Margin: <strong>Rp {{ number_format($totPokok, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Terbayar: <strong>Rp {{ number_format($totBayar, 0, ',', '.') }}</strong> &nbsp;|&nbsp;
    Sisa: <strong>Rp {{ number_format($totSisa, 0, ',', '.') }}</strong>
</div>
<table>
    <thead>
    <tr>
        <th>Kontrak</th><th>Tgl</th><th>Anggota</th><th>Barang</th>
        <th class="text-right">Total</th><th class="text-right">Cicilan</th>
        <th class="text-right">Terbayar</th><th class="text-right">Sisa</th><th>Status</th>
    </tr>
    </thead>
    <tbody>
    @foreach($financings as $f)
        <tr>
            <td>{{ $f->contract_number }}</td>
            <td>{{ optional($f->application_date)->format('d/m/Y') }}</td>
            <td>{{ optional($f->member)->full_name }}</td>
            <td>{{ $f->item_name }}</td>
            <td class="text-right">Rp {{ number_format($f->total_price, 0, ',', '.') }}</td>
            <td class="text-right">Rp {{ number_format($f->monthly_installment, 0, ',', '.') }}</td>
            <td class="text-right">Rp {{ number_format($f->total_paid, 0, ',', '.') }}</td>
            <td class="text-right">Rp {{ number_format($f->remaining, 0, ',', '.') }}</td>
            <td>{{ ucfirst($f->status) }}</td>
        </tr>
    @endforeach
    </tbody>
</table>
@endsection
