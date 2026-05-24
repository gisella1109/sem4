<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class FoodLog extends Model
{
    protected $table = 'food_logs';

    protected $fillable = [
        'user_id',
        'food_name',
        'meal_time',
        'calories',
        'carbs',
        'portion',
        'portion_unit',
        'notes',
        'input_method', // 'manual' atau 'photo'
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
