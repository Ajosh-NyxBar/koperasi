<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('products', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained('categories')->restrictOnDelete();
            $table->string('name');
            $table->string('sku', 50)->nullable()->unique();
            $table->text('description')->nullable();
            $table->decimal('base_price', 15, 2);
            $table->decimal('margin_percentage', 5, 2)->default(0);
            $table->integer('stock')->default(0);
            $table->string('image')->nullable();
            $table->boolean('is_available')->default(true)->index();
            $table->timestamps();
            $table->softDeletes();

            $table->index(['category_id', 'is_available']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('products');
    }
};
