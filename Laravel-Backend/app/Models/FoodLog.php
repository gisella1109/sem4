<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FoodLog extends Model
{
    protected $table = 'food_logs';

    protected $fillable = [
    'user_id',
    'food_id',

    'nama_manual',
    'waktu_makan',
    'gram',

    'kalori_manual',
    'karbo_manual',

    'protein_manual',
    'lemak_manual',

    'dicatat_pada',
];

    protected $casts = [
        'calories' => 'integer',
        'carbs'    => 'integer',
        'portion'  => 'double',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
