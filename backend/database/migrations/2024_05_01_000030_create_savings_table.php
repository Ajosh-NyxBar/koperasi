<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Saldo tabungan sukarela per anggota
        Schema::create('savings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->unique()->constrained('members')->cascadeOnDelete();
            $table->decimal('balance', 15, 2)->default(0);
            $table->timestamps();
        });

        // Transaksi tabungan sukarela
        Schema::create('saving_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('saving_id')->constrained('savings')->cascadeOnDelete();
            $table->enum('type', ['deposit', 'withdrawal']);
            $table->decimal('amount', 15, 2);
            $table->decimal('balance_after', 15, 2);
            $table->string('reference', 50)->nullable()->index();
            $table->string('description')->nullable();
            $table->date('transaction_date');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->index(['saving_id', 'transaction_date']);
            $table->index(['type', 'transaction_date']);
        });

        // Simpanan pokok (sekali bayar)
        Schema::create('principal_savings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->unique()->constrained('members')->cascadeOnDelete();
            $table->decimal('amount', 15, 2);
            $table->date('paid_date')->nullable();
            $table->enum('status', ['unpaid', 'paid'])->default('unpaid')->index();
            $table->timestamps();
        });

        // Simpanan wajib bulanan
        Schema::create('mandatory_savings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->constrained('members')->cascadeOnDelete();
            $table->string('period', 7); // YYYY-MM
            $table->decimal('amount', 15, 2);
            $table->date('due_date');
            $table->date('paid_date')->nullable();
            $table->enum('status', ['unpaid', 'paid', 'overdue'])->default('unpaid')->index();
            $table->foreignId('paid_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();

            $table->unique(['member_id', 'period']);
            $table->index(['period', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mandatory_savings');
        Schema::dropIfExists('principal_savings');
        Schema::dropIfExists('saving_transactions');
        Schema::dropIfExists('savings');
    }
};
