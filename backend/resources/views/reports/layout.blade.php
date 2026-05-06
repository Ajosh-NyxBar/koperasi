<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <title>@yield('title', 'Laporan KBMT')</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; font-size: 11px; color: #222; }
        h1 { font-size: 16px; margin: 0 0 4px 0; }
        h2 { font-size: 13px; margin: 0 0 12px 0; color: #555; }
        table { width: 100%; border-collapse: collapse; margin-top: 10px; }
        th { background: #1B5E20; color: #fff; text-align: left; padding: 6px; font-size: 10px; }
        td { padding: 5px 6px; border-bottom: 1px solid #eee; font-size: 10px; }
        tr:nth-child(even) td { background: #fafafa; }
        .header { border-bottom: 2px solid #1B5E20; padding-bottom: 6px; margin-bottom: 12px; }
        .footer { margin-top: 18px; font-size: 9px; color: #777; text-align: right; }
        .summary { background: #f0f7f0; padding: 8px 10px; margin: 8px 0; border-left: 3px solid #1B5E20; }
        .text-right { text-align: right; }
        .text-center { text-align: center; }
    </style>
</head>
<body>
<div class="header">
    <h1>KBMT - Koperasi Baitul Maal wat Tamwil</h1>
    <h2>@yield('subtitle')</h2>
</div>
@yield('content')
<div class="footer">Dicetak pada {{ now()->format('d M Y H:i') }} WIB</div>
</body>
</html>
