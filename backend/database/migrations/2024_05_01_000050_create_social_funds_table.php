<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        // Catatan kas dana sosial (in/out langsung, dicatat admin)
        Schema::create('social_funds', function (Blueprint $table) {
            $table->id();
            $table->foreignId('member_id')->nullable()->constrained('members')->nullOnDelete();
            $table->foreignId('application_id')->nullable(); // diisi di migration berikut
            $table->enum('type', ['infaq', 'zakat', 'bantuan_sakit', 'bantuan_pendidikan', 'kegiatan_sosial', 'shu', 'lainnya'])->index();
            $table->enum('direction', ['in', 'out'])->index();
            $table->decimal('amount', 15, 2);
            $table->text('description')->nullable();
            $table->date('transaction_date');
            $table->foreignId('created_by')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['type', 'transaction_date']);
            $table->index(['direction', 'transaction_date']);
        });

        // Pengajuan bantuan sosial oleh anggota -> butuh approval admin
        Schema::create('social_fund_applications', function (Blueprint $table) {
            $table->id();
            $table->string('application_number', 30)->unique();
            $table->foreignId('member_id')->constrained('members')->cascadeOnDelete();
            $table->enum('type', ['bantuan_sakit', 'bantuan_pendidikan', 'kegiatan_sosial', 'lainnya']);
            $table->decimal('requested_amount', 15, 2);
            $table->decimal('approved_amount', 15, 2)->nullable();
            $table->text('reason');
            $table->string('attachment')->nullable();
            $table->enum('status', ['pending', 'approved', 'rejected', 'disbursed'])->default('pending')->index();
            $table->date('application_date');
            $table->date('decided_date')->nullable();
            $table->foreignId('decided_by')->nullable()->constrained('users')->nullOnDelete();
            $table->text('admin_notes')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['member_id', 'status']);
        });

        // Hubungkan FK setelah dua tabel terbuat
        Schema::table('social_funds', function (Blueprint $table) {
            $table->foreign('application_id')->references('id')->on('social_fund_applications')->nullOnDelete();
        });
    }

    public function down(): void
    {
        Schema::table('social_funds', function (Blueprint $table) {
            $table->dropForeign(['application_id']);
        });
        Schema::dropIfExists('social_fund_applications');
        Schema::dropIfExists('social_funds');
    }
};
