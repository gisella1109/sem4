<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('foods', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('nama');
            $table->string('emoji')->default('🍽');
            $table->float('kalori_100g');
            $table->float('karbo_100g');
            $table->float('protein_100g');
            $table->float('lemak_100g');
            $table->float('serat_100g')->default(0);
            $table->float('gula_100g')->default(0);
            $table->string('kategori')->default('umum');
            $table->integer('indeks_glikemik')->default(50);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('foods'); }
};