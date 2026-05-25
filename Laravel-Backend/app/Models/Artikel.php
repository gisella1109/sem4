<?php
namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Artikel extends Model
{
    use HasFactory;

    protected $fillable = [
        'admin_id',
        'judul',
        'isi',
        'kategori',
        'ringkasan',
        'gambar',
        'is_published',
        'views',
    ];

    protected $casts = [
        'is_published' => 'boolean',
        'views'        => 'integer',
    ];

    public function admin()
    {
        return $this->belongsTo(User::class, 'admin_id');
    }

    // Hitung estimasi durasi baca (1 menit per 200 kata)
    public function getDuraBacaAttribute(): string
    {
        $kata   = str_word_count(strip_tags($this->isi));
        $menit  = max(1, round($kata / 200));
        return "$menit menit";
    }
}
