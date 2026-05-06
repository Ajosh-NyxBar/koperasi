# KBMT Backend - Koperasi Baitul Maal wat Tamwil

Backend REST API untuk aplikasi koperasi simpan-pinjam syariah, dibangun di atas **Laravel 12** + **MySQL** + **Sanctum** dengan arsitektur clean (Repository + Service + Form Request + API Resource).

## Stack

- PHP 8.2+, Laravel 12
- MySQL 8.x (port default 3306, project default 3308)
- Sanctum API token (mobile-friendly, no CSRF)
- `barryvdh/laravel-dompdf` untuk PDF report
- `maatwebsite/excel` untuk Excel report
- Database notifications channel (Laravel built-in)

## Struktur Folder

```
backend/
├─ app/
│  ├─ Console/Commands/        # Artisan commands (kbmt:daily)
│  ├─ Exports/                 # Maatwebsite Excel exporters
│  ├─ Http/
│  │  ├─ Controllers/Api/      # REST controllers (thin, delegate ke Service)
│  │  ├─ Middleware/           # AdminMiddleware, dll
│  │  ├─ Requests/             # FormRequest validators per domain
│  │  │  ├─ Auth/  Member/  Saving/  Financing/  Product/  SocialFund/
│  │  └─ Resources/            # API Resources (response shape)
│  ├─ Models/                  # Eloquent models
│  ├─ Notifications/           # Notification classes (database/mail)
│  ├─ Repositories/            # Repository pattern (Base + concrete)
│  │  └─ Contracts/            # Interface
│  ├─ Services/                # Business logic layer
│  └─ Traits/                  # ApiResponse trait
├─ database/
│  ├─ migrations/              # Schema (lihat docs/erd.md)
│  └─ seeders/                 # DatabaseSeeder dummy data
├─ resources/views/reports/    # Blade templates untuk PDF
├─ routes/
│  ├─ api.php                  # 56 endpoint
│  └─ console.php              # Schedule kbmt:daily
└─ docs/
   ├─ erd.md                   # Diagram & relasi tabel
   ├─ endpoints.md             # Daftar endpoint + contoh request/response
   └─ business-flow.md         # Flow bisnis tiap modul
```

## Setup

```bash
# 1. Install deps
composer install

# 2. Copy env & generate key (sudah otomatis)
cp .env.example .env
php artisan key:generate

# 3. Konfigurasi DB di .env (default sudah MySQL 127.0.0.1:3308 db kbmt_koperasi root no-password)

# 4. Migrate + seed
php artisan migrate:fresh --seed

# 5. Storage symlink (untuk foto profil & lampiran)
php artisan storage:link

# 6. Jalankan
php artisan serve
```

Akun default setelah seed:

| Role   | Email                | Password   |
|--------|----------------------|------------|
| Admin  | admin@kbmt.co.id     | admin123   |
| Member | siti@kbmt.co.id      | member123  |
| Member | ahmad@kbmt.co.id     | member123  |
| Member | budi@kbmt.co.id      | member123  |
| Member | dewi@kbmt.co.id      | member123  |
| Member | eko@kbmt.co.id       | member123  |

## Format Response

Semua endpoint API mengembalikan JSON konsisten:

```json
{ "success": true,  "message": "...", "data": { ... } }
{ "success": false, "message": "...", "data": null, "errors": { ... } }
```

## Scheduler

Jalankan harian (dijadwal jam 06:00):

```bash
php artisan kbmt:daily
```

Yang dikerjakan:
- Tandai cicilan jatuh tempo lewat → `overdue`
- Generate baris simpanan wajib bulan berjalan untuk semua member aktif
- Kirim reminder cicilan jatuh tempo H-3
- Kirim reminder simpanan wajib H-7

Aktifkan via cron (Linux) atau Task Scheduler (Windows):

```cron
* * * * * cd /path/to/backend && php artisan schedule:run >> /dev/null 2>&1
```

## Security

- **Sanctum token** (Bearer) untuk semua endpoint kecuali `/auth/login`, `/auth/register`, `/auth/forgot-password`, `/auth/verify-otp`, `/auth/reset-password`.
- **Rate limit** 10 request/menit pada endpoint auth publik (mitigasi brute force).
- **Role middleware** `admin` untuk endpoint admin-only.
- **Hash password** bcrypt 12 rounds.
- **Soft delete** pada users, members, products, categories, financings, social_funds, social_fund_applications.
- **Form Request validation** wajib di tiap endpoint write.

## Dokumentasi Lanjutan

- [docs/erd.md](docs/erd.md) — diagram relasi & detail kolom
- [docs/endpoints.md](docs/endpoints.md) — semua endpoint + contoh request/response
- [docs/business-flow.md](docs/business-flow.md) — flow bisnis per modul
