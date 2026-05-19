<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('gula_darahs', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->float('nilai_mgdl');
            $table->string('kondisi')->default('sewaktu');
            $table->text('catatan')->nullable();
            $table->timestamp('dicatat_pada')->useCurrent();
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('gula_darahs'); }
};