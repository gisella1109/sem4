<?php

namespace App\Http\Controllers;

use App\Models\FoodLog;
use Illuminate\Http\Request;

class FoodLogController extends Controller
{
    // GET /api/food-logs
    // Ambil semua log makanan (bisa filter by user_id, meal_time, tanggal)
    public function index(Request $request)
    {
        $query = FoodLog::query();

        // Filter user
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        // Filter waktu makan
        if ($request->has('meal_time')) {
            $query->where('meal_time', $request->meal_time);
        }

        // Filter tanggal (format: 2026-05-24)
        if ($request->has('date')) {
            $query->whereDate('created_at', $request->date);
        }

        // Filter metode input (manual / photo)
        if ($request->has('input_method')) {
            $query->where('input_method', $request->input_method);
        }

        $logs = $query->orderByDesc('created_at')->get();

        // Hitung total kalori & karbo
        $totalKalori = $logs->sum('calories');
        $totalKarbo  = $logs->sum('carbs');

        return response()->json([
            'status'       => 'success',
            'data'         => $logs,
            'total'        => $logs->count(),
            'total_kalori' => $totalKalori,
            'total_karbo'  => $totalKarbo,
        ]);
    }

    // POST /api/food-logs
    // Simpan log makanan baru (dari manual ATAU foto)
    public function store(Request $request)
    {
        $request->validate([
            'food_name'    => 'required|string|max:255',
            'meal_time'    => 'required|string',
            'calories'     => 'required|numeric|min:0',
            'carbs'        => 'required|numeric|min:0',
            'portion'      => 'required|numeric|min:0',
            'portion_unit' => 'required|string|max:100',
            'input_method' => 'required|in:manual,photo',
            'user_id'      => 'nullable|exists:users,id',
            'notes'        => 'nullable|string',
        ]);

        $log = FoodLog::create([
            'user_id'      => $request->user_id,
            'food_name'    => $request->food_name,
            'meal_time'    => $request->meal_time,
            'calories'     => (int) round($request->calories),
            'carbs'        => (int) round($request->carbs),
            'portion'      => $request->portion,
            'portion_unit' => $request->portion_unit,
            'notes'        => $request->notes,
            'input_method' => $request->input_method,
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Log makanan berhasil disimpan.',
            'data'    => $log,
        ], 201);
    }

    // GET /api/food-logs/{id}
    public function show($id)
    {
        $log = FoodLog::findOrFail($id);
        return response()->json([
            'status' => 'success',
            'data'   => $log,
        ]);
    }

    // PUT /api/food-logs/{id}
    public function update(Request $request, $id)
    {
        $log = FoodLog::findOrFail($id);

        $request->validate([
            'food_name'    => 'sometimes|string|max:255',
            'meal_time'    => 'sometimes|string',
            'calories'     => 'sometimes|numeric|min:0',
            'carbs'        => 'sometimes|numeric|min:0',
            'portion'      => 'sometimes|numeric|min:0',
            'portion_unit' => 'sometimes|string|max:100',
            'notes'        => 'nullable|string',
        ]);

        $log->update($request->only([
            'food_name', 'meal_time', 'calories',
            'carbs', 'portion', 'portion_unit', 'notes',
        ]));

        return response()->json([
            'status'  => 'success',
            'message' => 'Log makanan diperbarui.',
            'data'    => $log,
        ]);
    }

    // DELETE /api/food-logs/{id}
    public function destroy($id)
    {
        $log = FoodLog::findOrFail($id);
        $log->delete();

        return response()->json([
            'status'  => 'success',
            'message' => 'Log makanan dihapus.',
        ]);
    }

    // GET /api/food-logs/summary?user_id=1&date=2026-05-24
    // Ringkasan harian: total kalori, karbo, per waktu makan
    public function summary(Request $request)
    {
        $query = FoodLog::query();

        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        $tanggal = $request->date ?? now()->toDateString();
        $query->whereDate('created_at', $tanggal);

        $logs = $query->orderBy('created_at')->get();

        // Group by waktu makan
        $perWaktu = $logs->groupBy('meal_time')->map(function ($group, $waktu) {
            return [
                'waktu_makan'  => $waktu,
                'total_kalori' => $group->sum('calories'),
                'total_karbo'  => $group->sum('carbs'),
                'jumlah_item'  => $group->count(),
                'items'        => $group->values(),
            ];
        })->values();

        return response()->json([
            'status'       => 'success',
            'tanggal'      => $tanggal,
            'total_kalori' => $logs->sum('calories'),
            'total_karbo'  => $logs->sum('carbs'),
            'total_item'   => $logs->count(),
            'per_waktu'    => $perWaktu,
        ]);
    }
}
