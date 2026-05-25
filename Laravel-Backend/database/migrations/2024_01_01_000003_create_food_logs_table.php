<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('food_logs', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->constrained()->onDelete('cascade');
            $table->string('food_id')->nullable();  // FK ke foods (nullable kalau dari foto)
            $table->float('gram')->default(150);    // total gram porsi
            $table->string('waktu_makan');          // Sarapan, Siang, Malam, Cemilan
            $table->string('input_method')->default('manual'); // manual / photo

            // Field untuk input foto (AI detect) atau makanan tidak ada di DB
            $table->string('nama_manual')->nullable();
            $table->string('emoji_manual')->nullable();
            $table->float('kalori_manual')->nullable();
            $table->float('karbo_manual')->nullable();
            $table->float('gula_manual')->nullable();

            // Satuan alami (piring, mangkuk, biji, dll)
            $table->string('satuan')->nullable();
            $table->float('porsi')->default(1);

            $table->text('catatan')->nullable();
            $table->timestamp('dicatat_pada')->useCurrent();
            $table->timestamps();

            $table->foreign('food_id')->references('id')->on('foods')->onDelete('set null');
        });
    }

    public function down(): void { Schema::dropIfExists('food_logs'); }
};
