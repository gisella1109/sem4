<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\GulaDarah;
use Illuminate\Http\Request;

class GulaDarahController extends Controller
{
    // GET /api/gula-darah
    public function index(Request $request)
    {
        $query = GulaDarah::where('user_id', $request->user()->id);

        if ($request->filled('tanggal')) {
            $query->whereDate('dicatat_pada', $request->tanggal);
        }

        $data = $query->orderByDesc('dicatat_pada')->get();

        return response()->json(['success' => true, 'data' => $data]);
    }

    // POST /api/gula-darah
    public function store(Request $request)
    {
        $request->validate([
            'id'         => 'required|string',
            'nilai_mgdl' => 'required|numeric|min:1|max:1000',
            'kondisi'    => 'required|string',
        ]);

        $record = GulaDarah::create([
            'id'          => $request->id,
            'user_id'     => $request->user()->id,
            'nilai_mgdl'  => $request->nilai_mgdl,
            'kondisi'     => $request->kondisi,
            'catatan'     => $request->catatan,
            'dicatat_pada'=> $request->dicatat_pada ?? now(),
        ]);

        // Beri peringatan jika nilai tidak normal
        $peringatan = null;
        if ($request->nilai_mgdl < 70) {
            $peringatan = 'Gula darah terlalu rendah (hipoglikemia)! Segera konsumsi makanan/minuman manis.';
        } elseif ($request->nilai_mgdl > 200) {
            $peringatan = 'Gula darah sangat tinggi (hiperglikemia)! Segera konsultasi dokter.';
        } elseif ($request->nilai_mgdl > 130) {
            $peringatan = 'Gula darah di atas normal. Perhatikan pola makan hari ini.';
        }

        return response()->json([
            'success'    => true,
            'data'       => $record,
            'peringatan' => $peringatan,
        ], 201);
    }

    // DELETE /api/gula-darah/{id}
    public function destroy(Request $request, $id)
    {
        $record = GulaDarah::where('id', $id)
            ->where('user_id', $request->user()->id)
            ->first();

        if (!$record) {
            return response()->json(['success' => false, 'message' => 'Data tidak ditemukan'], 404);
        }

        $record->delete();
        return response()->json(['success' => true, 'message' => 'Berhasil dihapus']);
    }
}