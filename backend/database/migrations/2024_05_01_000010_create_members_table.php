<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('members', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('member_code', 20)->unique();
            $table->string('full_name');
            $table->string('nik', 16)->unique();
            $table->string('phone', 20)->nullable();
            $table->text('address')->nullable();
            $table->enum('gender', ['L', 'P']);
            $table->date('birth_date')->nullable();
            $table->string('birth_place')->nullable();
            $table->string('occupation')->nullable();
            $table->decimal('monthly_income', 15, 2)->nullable();
            $table->date('join_date');
            $table->enum('status', ['active', 'inactive', 'suspended'])->default('active')->index();
            $table->string('photo')->nullable();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['status', 'join_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('members');
    }
};
