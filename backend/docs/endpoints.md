# API Endpoints

Base URL: `http://127.0.0.1:8000/api`
Header default: `Accept: application/json`, untuk authenticated tambah `Authorization: Bearer <token>`.

Format response konsisten:
```json
{ "success": true|false, "message": "...", "data": ... }
```

---

## 1. Authentication (Public, rate-limited 10/menit)

### POST `/auth/register`

```json
{
  "full_name": "Test User",
  "email": "test@kbmt.co.id",
  "password": "test123",
  "password_confirmation": "test123",
  "nik": "3201019999990001",
  "phone": "08111",
  "gender": "L",
  "occupation": "Developer",
  "monthly_income": 5000000
}
```

Response 201:
```json
{
  "success": true,
  "message": "Registrasi berhasil",
  "data": {
    "user": { "id": 7, "name": "Test User", "email": "test@kbmt.co.id", "role": "member",
      "member": { "member_code": "KBMT-00006", "...": "..." } },
    "token": "7|xxxxxxxx"
  }
}
```

### POST `/auth/login`
```json
{ "email": "admin@kbmt.co.id", "password": "admin123" }
```
Response 200: `{ data: { user, token } }`

### POST `/auth/forgot-password`
```json
{ "email": "test@kbmt.co.id" }
```
Response: `{ data: { token: "<64-char>" } }` — kode OTP 6 digit dikirim via email (channel `mail`, default driver `log` jadi cek `storage/logs/laravel.log`).

### POST `/auth/verify-otp`
```json
{ "email": "test@kbmt.co.id", "otp": "123456" }
```
Response: `{ data: { token } }` (token bisa dipakai langsung di reset).

### POST `/auth/reset-password`
```json
{ "email": "test@kbmt.co.id", "token": "<token>", "password": "baru123", "password_confirmation": "baru123" }
```

---

## 2. Auth (Authenticated)

| Method | URL | Keterangan |
|---|---|---|
| POST | `/auth/logout` | Hapus token saat ini |
| GET  | `/auth/profile` | Profil user + member |
| POST/PUT | `/auth/profile` | Update profil (multipart untuk foto: field `photo`); butuh `current_password` jika ganti `password` |

Contoh update profil + foto (multipart):
```
POST /auth/profile
- name: "Nama Baru"
- phone: "08111"
- photo: <file jpg/png>
- current_password: "lama"
- password: "baru"
- password_confirmation: "baru"
```

---

## 3. Dashboard

### GET `/dashboard/admin` *(admin)*
Field utama: `total_members`, `total_savings`, `pending_financing`, `overdue_installments`, `social_fund_balance`, `monthly_stats[]` (6 bulan terakhir).

### GET `/dashboard/member` *(member)*
Field: `member`, `saving_balance`, `principal_saving`, `total_mandatory_savings`, `last_mandatory_saving`, `active_financings[]`, `next_installment`, `unread_notifications`.

---

## 4. Members CRUD *(admin)*

| Method | URL | Body |
|---|---|---|
| GET    | `/members?search=&status=&per_page=` | – |
| POST   | `/members` | full_name, email, password, nik, phone, gender, [birth_date, address, occupation, monthly_income, principal_saving_amount] |
| GET    | `/members/{id}` | – |
| PUT    | `/members/{id}` | partial update |
| DELETE | `/members/{id}` | soft delete + cascade user |

---

## 5. Savings

### Member
- GET `/savings/balance?type=deposit&from=2024-01-01&to=2024-12-31` → saldo + history
- GET `/savings/mandatory` → daftar simpanan wajib
- GET `/savings/principal` → simpanan pokok

### Admin
- POST `/savings/deposit` `{ member_id, amount, description? }`
- POST `/savings/withdraw` `{ member_id, amount, description? }`
- POST `/savings/mandatory/pay` `{ member_id, period: "2024-05", amount }`
- GET `/admin/savings`
- GET `/admin/mandatory-savings?period=2024-05`

---

## 6. Financing

### Read (member: hanya miliknya, admin: semua)
- GET `/financing?status=approved`
- GET `/financing/{id}`
- GET `/financing/{id}/installments`

### Simulasi *(authenticated)*
POST `/financing/simulate`
```json
{ "base_price": 3000000, "margin_percentage": 10, "tenor": 6 }
```
Response data:
```json
{ "total_price": 3300000, "monthly_installment": 550000, "schedule": [ ... ] }
```

### Pengajuan *(member atau admin)*
POST `/financing`
```json
{ "item_name": "Laptop ASUS", "base_price": 7000000, "margin_percentage": 10, "tenor": 12, "product_id": 5, "notes": "..." }
```
> Member tidak perlu kirim `member_id` (otomatis dari token). Admin **wajib** kirim `member_id`.

### Approval *(admin)*
- PUT `/financing/{id}/approve` → generate jadwal cicilan, kirim notifikasi member
- PUT `/financing/{id}/reject` `{ reason }` → kirim notifikasi
- POST `/financing/{id}/pay` `{ amount, installment_id?, penalty_paid?, method?, notes? }` → catat pembayaran cicilan + auto-complete saat lunas

---

## 7. Categories & Products

### Read (semua user)
- GET `/categories` & `/categories/{id}`
- GET `/products?category_id=2&search=samsung&only_available=1` & `/products/{id}`

### CRUD *(admin)*
- POST/PUT/DELETE `/categories[/{id}]`
- POST/PUT/DELETE `/products[/{id}]` (multipart `image` untuk upload)

---

## 8. Social Fund

### Pengajuan bantuan oleh member
- GET `/social-funds/applications?status=pending`
- POST `/social-funds/applications` (multipart: `type`, `requested_amount`, `reason`, `attachment` opsional)
- GET `/social-funds/applications/{id}`

### Admin
- GET `/social-funds?type=&direction=`
- POST `/social-funds` `{ type, direction:'in'|'out', amount, member_id?, description? }`
- PUT `/social-funds/applications/{id}/decide` `{ decision: 'approved'|'rejected', approved_amount?, admin_notes? }`
  - Saat approved → otomatis catat pengeluaran kas dana sosial dan ubah status ke `disbursed`.
  - Otomatis kirim notifikasi ke member.

---

## 9. Notifications

- GET `/notifications` → list + unread_count
- POST `/notifications/{uuid}/read`
- POST `/notifications/read-all`

Tipe notifikasi yang dikirim:
| category | sumber |
|---|---|
| `financing_approved` / `financing_rejected` / `financing_completed` | approve/reject/lunas |
| `installment_due` | scheduler harian (H-3 jatuh tempo) |
| `mandatory_saving_due` | scheduler harian (H-7) |
| `social_fund_approved` / `social_fund_rejected` / `social_fund_disbursed` | decision admin |

---

## 10. Reports *(admin)* — PDF & Excel

Format: query param `?format=pdf` (default) atau `?format=excel`.

| Endpoint | Filter |
|---|---|
| GET `/reports/members` | `status` |
| GET `/reports/savings` | `from`, `to` |
| GET `/reports/financings` | `status`, `from`, `to` |
| GET `/reports/social-funds` | `direction`, `from`, `to` |

Response berupa file download (`.pdf` / `.xlsx`).

---

## Contoh Curl

```bash
# Login
curl -X POST http://127.0.0.1:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@kbmt.co.id","password":"admin123"}'

# Dashboard
curl http://127.0.0.1:8000/api/dashboard/admin \
  -H "Authorization: Bearer <token>"

# Apply pembiayaan (member)
curl -X POST http://127.0.0.1:8000/api/financing \
  -H "Authorization: Bearer <member-token>" \
  -H "Content-Type: application/json" \
  -d '{"item_name":"Laptop","base_price":7000000,"margin_percentage":10,"tenor":12}'

# Download report
curl -L "http://127.0.0.1:8000/api/reports/financings?format=excel" \
  -H "Authorization: Bearer <admin-token>" \
  -o laporan.xlsx
```

## HTTP Status

| Code | Arti |
|---|---|
| 200 | OK |
| 201 | Created |
| 401 | Unauthenticated (token tidak ada/invalid) |
| 403 | Akses ditolak (bukan admin / bukan pemilik resource) |
| 404 | Resource tidak ditemukan |
| 422 | Validation error (`errors` field berisi detail field) |
| 429 | Rate limit terlampaui |
| 500 | Server error |
