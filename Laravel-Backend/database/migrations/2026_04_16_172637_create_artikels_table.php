<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void {
        Schema::create('artikels', function (Blueprint $table) {
            $table->id();
            $table->foreignId('admin_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('judul');
            $table->text('isi');
            $table->string('kategori')->default('Umum'); // Nutrisi, Gaya Hidup, Monitoring, Dasar
            $table->text('ringkasan')->nullable();       // preview singkat
            $table->string('gambar')->nullable();        // URL gambar
            $table->boolean('is_published')->default(false);
            $table->integer('views')->default(0);
            $table->timestamps();
        });
    }
    public function down(): void { Schema::dropIfExists('artikels'); }
};
