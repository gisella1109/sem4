<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\FoodLog;
use Illuminate\Http\Request;

class FoodLogController extends Controller
{
    // GET /api/food-logs
    public function index(Request $request)
    {
        $query = FoodLog::with('food')
            ->where('user_id', $request->user()->id);

        if ($request->filled('tanggal')) {
            $query->whereDate('dicatat_pada', $request->tanggal);
        }

        $logs = $query->orderByDesc('dicatat_pada')->get();

        // Hitung total nutrisi hari ini
        $today = now()->toDateString();
        $totalHariIni = FoodLog::where('user_id', $request->user()->id)
            ->whereDate('dicatat_pada', $today)
            ->with('food')
            ->get();

        $summary = [
            'total_kalori' => 0,
            'total_karbo'  => 0,
            'total_gula'   => 0,
            'total_protein'=> 0,
        ];

        foreach ($totalHariIni as $log) {
            $gram = $log->gram ?? 100;
            $f    = $log->food;

            $summary['total_kalori']  += $log->kalori_manual ?? ($f ? $f->kalori_100g  * $gram / 100 : 0);
            $summary['total_karbo']   += $log->karbo_manual  ?? ($f ? $f->karbo_100g   * $gram / 100 : 0);
            $summary['total_gula']    += $log->gula_manual   ?? ($f ? $f->gula_100g    * $gram / 100 : 0);
        }

        return response()->json([
            'success' => true,
            'data'    => $logs,
            'summary_hari_ini' => $summary,
            'peringatan_gula'  => $summary['total_gula'] > 25,
        ]);
    }

    // POST /api/food-logs
    public function store(Request $request)
    {
        $request->validate([
            'id'          => 'required|string',
            'gram'        => 'required|numeric',
            'waktu_makan' => 'required|string',
        ]);

        $log = FoodLog::create([
            'id'           => $request->id,
            'user_id'      => $request->user()->id,
            'food_id'      => $request->food_id,
            'gram'         => $request->gram,
            'waktu_makan'  => $request->waktu_makan,
            'nama_manual'  => $request->nama_manual,
            'emoji_manual' => $request->emoji_manual ?? '🍽',
            'kalori_manual'=> $request->kalori_manual,
            'karbo_manual' => $request->karbo_manual,
            'gula_manual'  => $request->gula_manual,
            'catatan'      => $request->catatan,
            'satuan'       => $request->satuan,
            'porsi'        => $request->porsi ?? 1,
            'dicatat_pada' => $request->dicatat_pada ?? now(),
        ]);

        return response()->json(['success' => true, 'data' => $log], 201);
    }

    // DELETE /api/food-logs/{id}
    public function destroy(Request $request, $id)
    {
        $log = FoodLog::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$log) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
        }

        $log->delete();
        return response()->json(['success' => true, 'message' => 'Berhasil dihapus']);
    }
}