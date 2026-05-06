<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Pengajuan & kontrak pembiayaan murabahah
        Schema::create('financings', function (Blueprint $table) {
            $table->id();
            $table->string('contract_number', 30)->unique();
            $table->foreignId('member_id')->constrained('members')->cascadeOnDelete();
            $table->foreignId('product_id')->nullable()->constrained('products')->nullOnDelete();
            $table->string('item_name');
            $table->decimal('base_price', 15, 2);
            $table->decimal('margin_percentage', 5, 2);
            $table->decimal('margin_amount', 15, 2);
            $table->decimal('total_price', 15, 2);
            $table->unsignedTinyInteger('tenor'); // bulan
            $table->decimal('monthly_installment', 15, 2);
            $table->decimal('total_paid', 15, 2)->default(0);
            $table->decimal('remaining', 15, 2);
            $table->decimal('penalty_per_day', 10, 2)->default(0); // denda per hari
            $table->enum('status', ['pending', 'approved', 'rejected', 'completed', 'defaulted'])
                ->default('pending')->index();
            $table->date('application_date');
            $table->date('approved_date')->nullable();
            $table->date('completed_date')->nullable();
            $table->foreignId('approved_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('notes')->nullable();
            $table->text('reject_reason')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['member_id', 'status']);
            $table->index(['status', 'application_date']);
        });

        // Jadwal cicilan otomatis (1 baris = 1 bulan)
        Schema::create('installments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('financing_id')->constrained('financings')->cascadeOnDelete();
            $table->unsignedTinyInteger('installment_number');
            $table->decimal('amount', 15, 2);
            $table->decimal('penalty_amount', 15, 2)->default(0);
            $table->decimal('paid_amount', 15, 2)->default(0);
            $table->date('due_date');
            $table->date('paid_date')->nullable();
            $table->enum('status', ['pending', 'partial', 'paid', 'overdue'])->default('pending')->index();
            $table->timestamps();

            $table->unique(['financing_id', 'installment_number']);
            $table->index(['status', 'due_date']);
        });

        // Catatan pembayaran cicilan (audit trail; 1 cicilan bisa banyak pembayaran)
        Schema::create('installment_payments', function (Blueprint $table) {
            $table->id();
            $table->foreignId('installment_id')->constrained('installments')->cascadeOnDelete();
            $table->foreignId('financing_id')->constrained('financings')->cascadeOnDelete();
            $table->string('receipt_number', 30)->unique();
            $table->decimal('amount', 15, 2);
            $table->decimal('penalty_paid', 15, 2)->default(0);
            $table->date('payment_date');
            $table->string('method', 30)->default('cash'); // cash/transfer/saving_balance
            $table->string('notes')->nullable();
            $table->foreignId('received_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['financing_id', 'payment_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('installment_payments');
        Schema::dropIfExists('installments');
        Schema::dropIfExists('financings');
    }
};
