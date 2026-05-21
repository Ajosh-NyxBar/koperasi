<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('penalty_settings', function (Blueprint $table) {
            $table->id();
            $table->string('name'); // e.g. "Default", "Ringan", "Berat"
            $table->decimal('penalty_per_day', 10, 2)->default(5000);
            $table->unsignedInteger('grace_period_days')->default(0); // hari toleransi sebelum denda berlaku
            $table->decimal('max_penalty_percentage', 5, 2)->default(0); // 0 = unlimited, e.g. 25 = max 25% dari pokok cicilan
            $table->boolean('is_default')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        // Tabel pencatatan keringanan denda
        Schema::create('penalty_waivers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('installment_id')->constrained('installments')->cascadeOnDelete();
            $table->foreignId('financing_id')->constrained('financings')->cascadeOnDelete();
            $table->decimal('original_penalty', 15, 2); // denda sebelum keringanan
            $table->decimal('waived_amount', 15, 2); // jumlah yang dibebaskan
            $table->decimal('final_penalty', 15, 2); // denda setelah keringanan
            $table->string('reason'); // alasan keringanan
            $table->foreignId('waived_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->index(['financing_id']);
            $table->index(['installment_id']);
        });

        // Tambah kolom waived_penalty di installments
        Schema::table('installments', function (Blueprint $table) {
            $table->decimal('waived_penalty', 15, 2)->default(0)->after('penalty_amount');
        });
    }

    public function down(): void
    {
        Schema::table('installments', function (Blueprint $table) {
            $table->dropColumn('waived_penalty');
        });
        Schema::dropIfExists('penalty_waivers');
        Schema::dropIfExists('penalty_settings');
    }
};
