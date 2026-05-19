<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Food extends Model {
    protected $primaryKey = 'id';
    public $incrementing  = false;
    protected $keyType    = 'string';
    protected $fillable   = [
        'id','nama','emoji','kalori_100g','karbo_100g','protein_100g',
        'lemak_100g','serat_100g','gula_100g','kategori','indeks_glikemik',
    ];
}

class FoodLog extends Model {
    protected $primaryKey = 'id';
    public $incrementing  = false;
    protected $keyType    = 'string';
    protected $fillable   = [
        'id','user_id','food_id','gram','waktu_makan','nama_manual',
        'emoji_manual','kalori_manual','karbo_manual','gula_manual',
        'catatan','satuan','porsi','dicatat_pada',
    ];

    public function food() {
        return $this->belongsTo(Food::class, 'food_id');
    }
    public function user() {
        return $this->belongsTo(User::class);
    }
}

class GulaDarah extends Model {
    protected $primaryKey = 'id';
    public $incrementing  = false;
    protected $keyType    = 'string';
    protected $fillable   = ['id','user_id','nilai_mgdl','kondisi','catatan','dicatat_pada'];

    public function user() {
        return $this->belongsTo(User::class);
    }
}