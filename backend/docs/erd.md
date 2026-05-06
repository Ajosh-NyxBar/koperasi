# ERD - KBMT Database

Semua tabel pakai `id` BIGINT auto-increment, `timestamps`, dan **soft delete** untuk entitas master.

## Diagram Relasi (textual)

```
users (1) ────< members (1) ────< savings (1) ────< saving_transactions
                          │
                          ├──< principal_savings (1)
                          ├──< mandatory_savings (banyak, unique[member_id, period])
                          ├──< financings (banyak)
                          │       ├──< installments (banyak, unique[fin_id, num])
                          │       │       └──< installment_payments
                          │       └── product (belongsTo)
                          ├──< social_fund_applications (banyak)
                          │       └── social_funds (1, application_id)
                          └──< social_funds (banyak)

categories (1) ────< products (banyak)
users (1) ────< notifications (polymorphic)
password_otps (independent)
```

## Detail Tabel

### users
- id, name, email *(unique)*, email_verified_at, password
- **role** ENUM('admin','member') default 'member' *(indexed)*
- **is_active** boolean default true
- timestamps, **softDeletes**

### members
- id, user_id *(FK→users, cascade)*, member_code *(unique)*, full_name, nik *(unique 16)*, phone, address
- gender ENUM('L','P'), birth_date, birth_place, occupation, monthly_income decimal(15,2)
- join_date, status ENUM('active','inactive','suspended'), photo
- timestamps, **softDeletes** | index: status, [status,join_date]

### categories
- id, name *(unique)*, icon, description, is_active
- timestamps, **softDeletes**

### products
- id, category_id *(FK restrict)*, name, sku *(unique)*, description
- base_price, margin_percentage, **stock**, image, is_available
- timestamps, **softDeletes** | index: [category_id,is_available]

### savings (saldo sukarela)
- id, member_id *(unique FK cascade)*, balance decimal(15,2), timestamps

### saving_transactions
- id, saving_id *(FK cascade)*, type ENUM('deposit','withdrawal'),
- amount, **balance_after**, reference, description, transaction_date, created_by *(FK→users null)*
- index: [saving_id,transaction_date], [type,transaction_date]

### principal_savings
- id, member_id *(unique FK cascade)*, amount, paid_date, status ENUM('unpaid','paid')

### mandatory_savings
- id, member_id *(FK cascade)*, period CHAR(7) "YYYY-MM", amount, due_date, paid_date
- status ENUM('unpaid','paid','overdue'), paid_by *(FK→users null)*
- **unique[member_id, period]**, index: [period,status]

### financings (kontrak murabahah)
- id, **contract_number** *(unique, FIN-YYYYMM-NNNNN)*
- member_id *(FK cascade)*, product_id *(FK nullable null-on-delete)*, item_name
- base_price, margin_percentage, margin_amount, total_price
- tenor (1-60), monthly_installment, total_paid, remaining
- **penalty_per_day** (denda)
- status ENUM('pending','approved','rejected','completed','defaulted')
- application_date, approved_date, completed_date, approved_by *(FK→users null)*
- notes, reject_reason, timestamps, **softDeletes**
- index: [member_id,status], [status,application_date]

### installments (jadwal cicilan)
- id, financing_id *(FK cascade)*, installment_number, amount
- **penalty_amount**, **paid_amount**, due_date, paid_date
- status ENUM('pending','partial','paid','overdue')
- **unique[financing_id,installment_number]**, index: [status,due_date]

### installment_payments (audit trail pembayaran)
- id, installment_id *(FK cascade)*, financing_id *(FK cascade)*
- **receipt_number** *(unique)*, amount, penalty_paid, payment_date
- method (cash/transfer/saving_balance), notes, received_by *(FK→users null)*

### social_funds (kas dana sosial)
- id, member_id *(FK null)*, application_id *(FK→social_fund_applications null)*
- type ENUM('infaq','zakat','bantuan_sakit','bantuan_pendidikan','kegiatan_sosial','shu','lainnya')
- direction ENUM('in','out'), amount, description, transaction_date, created_by
- timestamps, **softDeletes**

### social_fund_applications (pengajuan bantuan)
- id, **application_number** *(unique, APP-YYYYMM-NNNN)*, member_id
- type, requested_amount, approved_amount, reason, attachment
- status ENUM('pending','approved','rejected','disbursed')
- application_date, decided_date, decided_by, admin_notes
- timestamps, **softDeletes**

### notifications (Laravel default, database channel)
- uuid id, type, notifiable_type+id, data (JSON), read_at, timestamps

### password_otps (forgot password)
- id, email, otp (6 digit), token (64 char unique), expires_at, used_at, attempts

## Index Performansi

Sudah ditambahkan secara strategis di kolom yang paling sering jadi filter:

- `members.status` (filter aktif/inaktif)
- `mandatory_savings.[period,status]` (rekap bulanan)
- `installments.[status,due_date]` (cek overdue)
- `financings.[member_id,status]` & `[status,application_date]` (list per member & per status)
- `saving_transactions.[saving_id,transaction_date]` (mutasi)
