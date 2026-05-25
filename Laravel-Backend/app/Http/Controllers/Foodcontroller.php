<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Food;
use Illuminate\Http\Request;

class FoodController extends Controller
{
    // GET /api/foods
    public function index(Request $request)
    {
        $query = Food::query();

        if ($request->filled('q')) {
            $query->where('nama', 'LIKE', '%' . $request->q . '%');
        }
        if ($request->filled('kategori')) {
            $query->where('kategori', $request->kategori);
        }

        $foods = $query->orderBy('nama')->get();

        return response()->json(['success' => true, 'data' => $foods]);
    }

    // GET /api/foods/{id}
    public function show($id)
    {
        $food = Food::find($id);
        if (!$food) {
            return response()->json(['success' => false, 'message' => 'Makanan tidak ditemukan'], 404);
        }
        return response()->json(['success' => true, 'data' => $food]);
    }

    // GET /api/foods/low-gi
    public function lowGI()
    {
        $foods = Food::where('indeks_glikemik', '>', 0)
            ->where('indeks_glikemik', '<', 55)
            ->orderBy('indeks_glikemik')
            ->get();
        return response()->json(['success' => true, 'data' => $foods]);
    }
}