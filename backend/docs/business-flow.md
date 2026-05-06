# Flow Bisnis KBMT

## 1. Registrasi Anggota

```
[Calon anggota] → POST /auth/register
                    ├─ buat User (role=member)
                    ├─ buat Member (member_code KBMT-NNNNN auto-gen)
                    ├─ buat Saving (balance=0)
                    └─ buat PrincipalSaving (Rp 100.000 unpaid)
                  ← token + user data
```

Saat admin membuat anggota lewat `POST /members`, principal_saving_amount bisa langsung diset paid.

## 2. Login & Forgot Password

- Login standar (Sanctum token).
- Forgot password berbasis OTP 6-digit + token (random 64 char):
  1. `POST /auth/forgot-password` → record di `password_otps`, kirim email (Notification mail channel).
  2. `POST /auth/verify-otp` → cek OTP belum expired & belum dipakai, return token.
  3. `POST /auth/reset-password` → ganti password, mark `used_at`, revoke semua token sanctum lama.

OTP berlaku **10 menit**. Single-use (`used_at` di-set saat reset sukses).

## 3. Tabungan (3 jenis)

### Simpanan Pokok
- Sekali bayar saat masuk anggota (default Rp 100.000).
- Dibuat otomatis saat register/admin create member.

### Simpanan Wajib (bulanan)
- Scheduler harian `kbmt:daily` membuat baris `mandatory_savings` setiap awal bulan untuk member aktif (Rp 50.000 default).
- Status: `unpaid` → `paid` (admin kirim `POST /savings/mandatory/pay`) → otomatis `overdue` jika lewat tanggal due_date.
- Reminder dikirim H-7 ke member yang masih unpaid.

### Tabungan Sukarela (savings)
- Saldo per member, bisa setor & tarik kapan saja oleh admin.
- Setiap transaksi tercatat di `saving_transactions` dengan `balance_after` snapshot (audit trail).
- Validasi: tarik tidak boleh > saldo (lockForUpdate untuk prevent race condition).

## 4. Pembiayaan (Murabahah)

```
[member] POST /financing  (item, base_price, margin%, tenor)
            └─> Financing(status='pending', contract_number=FIN-YYYYMM-NNNNN)

[admin]  PUT /financing/{id}/approve
            ├─> status='approved', approved_date, approved_by
            ├─> generate Installments per bulan (tenor x baris)
            └─> Notification 'Pembiayaan Disetujui' ke member

[admin]  PUT /financing/{id}/reject  (reason)
            ├─> status='rejected', reject_reason
            └─> Notification 'Pembiayaan Ditolak'

[admin]  POST /financing/{id}/pay  (amount, [installment_id, penalty_paid, method])
            ├─> Pilih cicilan target: installment_id atau pending paling awal
            ├─> Update Installment.paid_amount; status='paid' jika lunas, else 'partial'
            ├─> Catat InstallmentPayment (receipt_number unik) sebagai audit trail
            ├─> Tambah Financing.total_paid, kurangi remaining
            └─> Jika remaining<=0 → status='completed', kirim notif 'Pembiayaan Lunas'
```

### Denda Keterlambatan
- Field `financings.penalty_per_day` (default Rp 5.000).
- `Installment::calculatePenalty()` hitung hari overdue × tarif.
- Pembayaran cicilan menerima field `penalty_paid` (terpisah dari `amount`).

### Auto Overdue
- Scheduler harian update `installments.status` jadi `overdue` untuk yang `due_date < today` dan masih `pending`/`partial`.

## 5. Produk & Kategori

- Admin CRUD penuh.
- Produk punya `stock`, `image`, `is_available`. Saat upload, file disimpan di `storage/app/public/products/`.
- Soft delete dipakai (data tidak hilang, bisa restore manual).
- Selling price = base_price × (1 + margin/100), dihitung di accessor `Product::selling_price`.

## 6. Dana Sosial

### Direct (admin catat langsung)
- `POST /social-funds` — type (infaq/zakat/dll), direction (in/out), amount.

### Pengajuan Bantuan (alur approval)
```
[member] POST /social-funds/applications  (type, requested_amount, reason, attachment?)
            └─> SocialFundApplication(status='pending', application_number=APP-YYYYMM-NNNN)

[admin]  PUT /social-funds/applications/{id}/decide
            ├─ decision='rejected' → status='rejected', notif ke member
            └─ decision='approved' → status='approved', approved_amount
                ├─ buat SocialFund(direction='out', application_id=X) — pencairan
                ├─ status update ke 'disbursed'
                └─ notif ke member
```

## 7. Notifikasi (database channel)

Semua notifikasi tersimpan di tabel `notifications` (UUID). Member fetch lewat `GET /notifications`. Reminder dispatch oleh scheduler.

| Trigger | Notification class |
|---|---|
| Financing approve/reject/complete | FinancingStatusNotification |
| Installment H-3 jatuh tempo / overdue | InstallmentDueNotification |
| Mandatory saving H-7 unpaid / overdue | MandatorySavingDueNotification |
| Social fund application approved/rejected/disbursed | SocialFundApplicationStatusNotification |
| Forgot password | PasswordResetOtpNotification (mail) |

## 8. Laporan

- Semua laporan butuh role admin.
- 4 jenis: Anggota, Tabungan, Pembiayaan, Dana Sosial.
- 2 format per jenis: PDF (Blade + Dompdf) & Excel (Maatwebsite).
- Filter via query param: status / from-to / direction.
- Excel header bold, PDF pakai layout standar dengan kop KBMT + ringkasan total.

## 9. Job Harian (`kbmt:daily`)

Idempotent, aman dijalankan beberapa kali sehari:

1. **Mark overdue** — installments `pending`/`partial` & `due_date < today` → `overdue`.
2. **Generate mandatory** — buat baris `mandatory_savings` untuk bulan berjalan bagi member aktif yang belum punya.
3. **Reminder cicilan** — kirim notif untuk installments dengan `due_date <= today+3` (member terkait).
4. **Reminder simpanan wajib** — kirim notif untuk `unpaid`/`overdue` dengan `due_date <= today+7`.

## 10. Multi-Tenant Security

- Member hanya bisa baca/aksi data miliknya:
  - `/financing` index difilter `member_id = user.member.id` jika non-admin.
  - `/financing/{id}` & `/financing/{id}/installments` cek kepemilikan.
  - `/social-funds/applications` index difilter sama.
- Endpoint admin dilindungi middleware `admin`.
