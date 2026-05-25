<?php
namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Artikel;
use Illuminate\Http\Request;

class ArtikelController extends Controller
{
   
    public function index(Request $request)
    {
        $query = Artikel::with('admin:id,nama,name')
            ->where('is_published', true);

        if ($request->filled('kategori') && $request->kategori !== 'Semua') {
            $query->where('kategori', $request->kategori);
        }
        if ($request->filled('q')) {
            $query->where('judul', 'LIKE', '%' . $request->q . '%');
        }

        $artikels = $query->orderByDesc('created_at')->get()
            ->map(fn($a) => $this->_format($a));

        return response()->json(['success' => true, 'data' => $artikels]);
    }

    // detail artikel + tambah views
    public function show($id)
    {
        $artikel = Artikel::with('admin:id,nama,name')
            ->where('is_published', true)
            ->findOrFail($id);

        $artikel->increment('views');

        return response()->json(['success' => true, 'data' => $this->_format($artikel)]);
    }

    //  semua artikel (terbit + draf)
    public function adminIndex(Request $request)
    {
        $query = Artikel::with('admin:id,nama,name');

        if ($request->filled('kategori') && $request->kategori !== 'Semua') {
            $query->where('kategori', $request->kategori);
        }
        if ($request->filled('q')) {
            $query->where('judul', 'LIKE', '%' . $request->q . '%');
        }
        if ($request->filled('status')) {
            $query->where('is_published', $request->status === 'terbit');
        }

        $artikels = $query->orderByDesc('created_at')->get()
            ->map(fn($a) => $this->_format($a));

        return response()->json([
            'success'          => true,
            'data'             => $artikels,
            'total'            => $artikels->count(),
            'total_terbit'     => Artikel::where('is_published', true)->count(),
            'total_draf'       => Artikel::where('is_published', false)->count(),
            'total_views'      => Artikel::sum('views'),
        ]);
    }

    // buat artikel baru
    public function store(Request $request)
    {
        $request->validate([
            'judul'        => 'required|string|max:255',
            'isi'          => 'required|string',
            'kategori'     => 'required|string',
            'is_published' => 'boolean',
            'ringkasan'    => 'nullable|string|max:300',
            'gambar'       => 'nullable|string',
        ]);

        $artikel = Artikel::create([
            'admin_id'     => $request->user()->id,
            'judul'        => $request->judul,
            'isi'          => $request->isi,
            'kategori'     => $request->kategori,
            'ringkasan'    => $request->ringkasan ?? substr(strip_tags($request->isi), 0, 200),
            'gambar'       => $request->gambar,
            'is_published' => $request->is_published ?? false,
            'views'        => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => $artikel->is_published ? 'Artikel berhasil diterbitkan!' : 'Artikel disimpan sebagai draf.',
            'data'    => $this->_format($artikel->load('admin:id,nama,name')),
        ], 201);
    }

    // update artikel
    public function update(Request $request, $id)
    {
        $artikel = Artikel::findOrFail($id);

        if ($artikel->admin_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan'], 403);
        }

        $request->validate([
            'judul'        => 'sometimes|string|max:255',
            'isi'          => 'sometimes|string',
            'kategori'     => 'sometimes|string',
            'is_published' => 'sometimes|boolean',
            'ringkasan'    => 'nullable|string|max:300',
            'gambar'       => 'nullable|string',
        ]);

        $data = $request->only(['judul', 'isi', 'kategori', 'is_published', 'ringkasan', 'gambar']);

        if (isset($data['isi']) && !isset($data['ringkasan'])) {
            $data['ringkasan'] = substr(strip_tags($data['isi']), 0, 200);
        }

        $artikel->update($data);

        return response()->json([
            'success' => true,
            'message' => 'Artikel berhasil diperbarui.',
            'data'    => $this->_format($artikel->load('admin:id,nama,name')),
        ]);
    }

    // DELETE 
    public function destroy(Request $request, $id)
    {
        $artikel = Artikel::findOrFail($id);

        if ($artikel->admin_id !== $request->user()->id && $request->user()->role !== 'admin') {
            return response()->json(['success' => false, 'message' => 'Tidak diizinkan'], 403);
        }

        $artikel->delete();

        return response()->json(['success' => true, 'message' => 'Artikel berhasil dihapus.']);
    }


    private function _format(Artikel $a): array
    {
        return [
            'id'           => $a->id,
            'judul'        => $a->judul,
            'isi'          => $a->isi,
            'ringkasan'    => $a->ringkasan ?? substr(strip_tags($a->isi), 0, 150) . '...',
            'kategori'     => $a->kategori,
            'gambar'       => $a->gambar,
            'is_published' => $a->is_published,
            'views'        => $a->views,
            'dura_baca'    => $a->dura_baca,
            'admin'        => $a->admin ? ($a->admin->nama ?? $a->admin->name) : 'Admin',
            'created_at'   => $a->created_at?->format('d M Y'),
            'updated_at'   => $a->updated_at?->format('d M Y'),
        ];
    }
}
