<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Financing;
use App\Models\Installment;
use App\Models\InstallmentPayment;
use App\Models\MandatorySaving;
use App\Models\Member;
use App\Models\PrincipalSaving;
use App\Models\Product;
use App\Models\Saving;
use App\Models\SavingTransaction;
use App\Models\SocialFund;
use App\Models\SocialFundApplication;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // ============== Admin ==============
        $admin = User::create([
            'name'     => 'Admin KBMT',
            'email'    => 'admin@kbmt.co.id',
            'password' => Hash::make('admin123'),
            'role'     => 'admin',
        ]);

        // ============== Categories ==============
        $catData = [
            ['name' => 'Sembako',         'icon' => 'shopping_basket', 'description' => 'Kebutuhan pokok sehari-hari'],
            ['name' => 'Elektronik',      'icon' => 'devices',         'description' => 'HP, Laptop, TV, dll'],
            ['name' => 'Peralatan Rumah', 'icon' => 'home',            'description' => 'Mesin cuci, AC, Kulkas'],
            ['name' => 'Kendaraan',       'icon' => 'two_wheeler',     'description' => 'Motor dan aksesoris'],
            ['name' => 'Lainnya',         'icon' => 'category',        'description' => 'Kebutuhan lainnya'],
        ];
        foreach ($catData as $c) Category::create($c);

        // ============== Products ==============
        $prodData = [
            ['category_id' => 1, 'name' => 'Paket Sembako A',      'sku' => 'SEM-A',     'base_price' => 500000,   'margin_percentage' => 5,  'stock' => 50, 'description' => 'Beras, minyak, gula, dll'],
            ['category_id' => 1, 'name' => 'Paket Sembako B',      'sku' => 'SEM-B',     'base_price' => 1000000,  'margin_percentage' => 5,  'stock' => 30, 'description' => 'Paket lengkap bulanan'],
            ['category_id' => 2, 'name' => 'Samsung Galaxy A15',   'sku' => 'HP-SAM-A15','base_price' => 2500000,  'margin_percentage' => 10, 'stock' => 10, 'description' => 'HP Android 128GB'],
            ['category_id' => 2, 'name' => 'iPhone 14',            'sku' => 'HP-IP-14',  'base_price' => 12000000, 'margin_percentage' => 10, 'stock' => 5,  'description' => 'Apple iPhone 14 128GB'],
            ['category_id' => 2, 'name' => 'Laptop ASUS VivoBook', 'sku' => 'LP-ASUS-VB','base_price' => 7000000,  'margin_percentage' => 10, 'stock' => 8,  'description' => 'Laptop 14 inch'],
            ['category_id' => 3, 'name' => 'Mesin Cuci Samsung',   'sku' => 'MC-SAM-7K', 'base_price' => 3500000,  'margin_percentage' => 8,  'stock' => 6,  'description' => '7kg Top Loading'],
            ['category_id' => 3, 'name' => 'AC Daikin 1PK',        'sku' => 'AC-DK-1PK', 'base_price' => 4500000,  'margin_percentage' => 8,  'stock' => 4,  'description' => 'AC Split 1 PK'],
            ['category_id' => 3, 'name' => 'Kulkas LG 2 Pintu',    'sku' => 'KL-LG-2P',  'base_price' => 4000000,  'margin_percentage' => 8,  'stock' => 5,  'description' => '234 Liter'],
            ['category_id' => 4, 'name' => 'Honda Beat',           'sku' => 'MT-HND-BT', 'base_price' => 17000000, 'margin_percentage' => 12, 'stock' => 3,  'description' => 'Honda Beat 2024'],
            ['category_id' => 4, 'name' => 'Yamaha NMAX',          'sku' => 'MT-YMH-NM', 'base_price' => 30000000, 'margin_percentage' => 12, 'stock' => 2,  'description' => 'Yamaha NMAX 155'],
        ];
        foreach ($prodData as $p) Product::create($p);

        // ============== Members ==============
        $memberData = [
            ['name' => 'Ahmad Suryadi',   'email' => 'ahmad@kbmt.co.id', 'nik' => '3201011234560001', 'phone' => '081234567891', 'gender' => 'L', 'occupation' => 'Pedagang',  'income' => 5000000],
            ['name' => 'Siti Nurhaliza',  'email' => 'siti@kbmt.co.id',  'nik' => '3201011234560002', 'phone' => '081234567892', 'gender' => 'P', 'occupation' => 'Guru',      'income' => 4500000],
            ['name' => 'Budi Santoso',    'email' => 'budi@kbmt.co.id',  'nik' => '3201011234560003', 'phone' => '081234567893', 'gender' => 'L', 'occupation' => 'Karyawan',  'income' => 6000000],
            ['name' => 'Dewi Rahayu',     'email' => 'dewi@kbmt.co.id',  'nik' => '3201011234560004', 'phone' => '081234567894', 'gender' => 'P', 'occupation' => 'Wirausaha', 'income' => 8000000],
            ['name' => 'Eko Prasetyo',    'email' => 'eko@kbmt.co.id',   'nik' => '3201011234560005', 'phone' => '081234567895', 'gender' => 'L', 'occupation' => 'PNS',       'income' => 7500000],
        ];

        foreach ($memberData as $i => $m) {
            $user = User::create([
                'name' => $m['name'], 'email' => $m['email'],
                'password' => Hash::make('member123'), 'role' => 'member',
            ]);

            $joinDate = Carbon::now()->subMonths(rand(3, 12));
            $member = Member::create([
                'user_id'        => $user->id,
                'member_code'    => 'KBMT-' . str_pad((string)($i + 1), 5, '0', STR_PAD_LEFT),
                'full_name'      => $m['name'],
                'nik'            => $m['nik'],
                'phone'          => $m['phone'],
                'address'        => 'Jl. Contoh No. ' . ($i + 1) . ', Purwakarta',
                'gender'         => $m['gender'],
                'birth_date'     => Carbon::now()->subYears(rand(25, 45))->subDays(rand(1, 365)),
                'birth_place'    => 'Purwakarta',
                'occupation'     => $m['occupation'],
                'monthly_income' => $m['income'],
                'join_date'      => $joinDate,
                'status'         => 'active',
            ]);

            // Saving + initial deposit
            $balance = rand(500_000, 5_000_000);
            $saving = Saving::create(['member_id' => $member->id, 'balance' => $balance]);
            SavingTransaction::create([
                'saving_id'        => $saving->id,
                'type'             => 'deposit',
                'amount'           => $balance,
                'balance_after'    => $balance,
                'reference'        => 'INIT-' . $member->member_code,
                'description'      => 'Saldo awal',
                'transaction_date' => $joinDate->toDateString(),
                'created_by'       => $admin->id,
            ]);

            // Principal saving
            PrincipalSaving::create([
                'member_id' => $member->id,
                'amount'    => 100000,
                'paid_date' => $joinDate,
                'status'    => 'paid',
            ]);

            // Mandatory savings (6 bulan terakhir)
            for ($j = 5; $j >= 0; $j--) {
                $date = Carbon::now()->subMonths($j);
                $period = $date->format('Y-m');
                $isPaid = $j > 0 || rand(0, 1);
                MandatorySaving::create([
                    'member_id' => $member->id,
                    'period'    => $period,
                    'amount'    => 50000,
                    'due_date'  => $date->copy()->endOfMonth()->toDateString(),
                    'paid_date' => $isPaid ? $date->copy()->day(rand(1, 25)) : null,
                    'status'    => $isPaid ? 'paid' : 'unpaid',
                    'paid_by'   => $isPaid ? $admin->id : null,
                ]);
            }
        }

        // ============== Sample Financing ==============
        $member1 = Member::find(1);
        $approvedDate = now()->subMonths(3);
        $financing = Financing::create([
            'contract_number'     => 'FIN-' . $approvedDate->format('Ym') . '-00001',
            'member_id'           => $member1->id,
            'product_id'          => 3,
            'item_name'           => 'Samsung Galaxy A15',
            'base_price'          => 2500000,
            'margin_percentage'   => 10,
            'margin_amount'       => 250000,
            'total_price'         => 2750000,
            'tenor'               => 6,
            'monthly_installment' => 458334,
            'total_paid'          => 916668,
            'remaining'           => 1833332,
            'penalty_per_day'     => 5000,
            'status'              => 'approved',
            'application_date'    => $approvedDate->copy()->subDays(2),
            'approved_date'       => $approvedDate,
            'approved_by'         => $admin->id,
        ]);

        for ($k = 1; $k <= 6; $k++) {
            $due = $approvedDate->copy()->addMonths($k);
            $isPaid = $k <= 2;
            $inst = Installment::create([
                'financing_id'       => $financing->id,
                'installment_number' => $k,
                'amount'             => 458334,
                'paid_amount'        => $isPaid ? 458334 : 0,
                'due_date'           => $due->toDateString(),
                'paid_date'          => $isPaid ? $due->toDateString() : null,
                'status'             => $isPaid ? 'paid' : 'pending',
            ]);

            if ($isPaid) {
                InstallmentPayment::create([
                    'installment_id' => $inst->id,
                    'financing_id'   => $financing->id,
                    'receipt_number' => 'RCP-SEED-' . $inst->id,
                    'amount'         => 458334,
                    'payment_date'   => $due->toDateString(),
                    'method'         => 'cash',
                    'received_by'    => $admin->id,
                ]);
            }
        }

        // Pengajuan pembiayaan pending dari member 2
        $member2 = Member::find(2);
        Financing::create([
            'contract_number'     => 'FIN-' . now()->format('Ym') . '-00002',
            'member_id'           => $member2->id,
            'product_id'          => 6,
            'item_name'           => 'Mesin Cuci Samsung',
            'base_price'          => 3500000,
            'margin_percentage'   => 8,
            'margin_amount'       => 280000,
            'total_price'         => 3780000,
            'tenor'               => 12,
            'monthly_installment' => 315000,
            'total_paid'          => 0,
            'remaining'           => 3780000,
            'penalty_per_day'     => 5000,
            'status'              => 'pending',
            'application_date'    => now()->subDays(2),
        ]);

        // ============== Social Funds ==============
        SocialFund::create([
            'member_id' => null, 'type' => 'infaq', 'direction' => 'in',
            'amount' => 500000, 'description' => 'Infaq bulanan anggota',
            'transaction_date' => now()->subDays(15), 'created_by' => $admin->id,
        ]);
        SocialFund::create([
            'member_id' => 2, 'type' => 'bantuan_sakit', 'direction' => 'out',
            'amount' => 200000, 'description' => 'Bantuan sakit Siti',
            'transaction_date' => now()->subDays(5), 'created_by' => $admin->id,
        ]);
        SocialFund::create([
            'member_id' => null, 'type' => 'kegiatan_sosial', 'direction' => 'out',
            'amount' => 300000, 'description' => 'Santunan anak yatim',
            'transaction_date' => now()->subDays(10), 'created_by' => $admin->id,
        ]);

        // Pengajuan bantuan pending
        SocialFundApplication::create([
            'application_number' => 'APP-' . now()->format('Ym') . '-0001',
            'member_id'          => 3,
            'type'               => 'bantuan_pendidikan',
            'requested_amount'   => 500000,
            'reason'             => 'Bantuan biaya sekolah anak menjelang tahun ajaran baru.',
            'status'             => 'pending',
            'application_date'   => now()->subDays(1),
        ]);
    }
}
