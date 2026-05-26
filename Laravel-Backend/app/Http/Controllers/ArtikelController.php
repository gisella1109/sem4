<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Artikel;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class ArtikelController extends Controller
{
    // GET /api/artikels — untuk PASIEN (hanya yang published)
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

    // GET /api/artikels/{id}
    public function show($id)
    {
        $artikel = Artikel::with('admin:id,nama,name')
            ->where('is_published', true)
            ->findOrFail($id);

        $artikel->increment('views');

        return response()->json(['success' => true, 'data' => $this->_format($artikel)]);
    }

    // GET /api/admin/artikels — untuk ADMIN (semua)
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
            'success'       => true,
            'data'          => $artikels,
            'total'         => $artikels->count(),
            'total_terbit'  => Artikel::where('is_published', true)->count(),
            'total_draf'    => Artikel::where('is_published', false)->count(),
            'total_views'   => Artikel::sum('views'),
        ]);
    }

    // POST /api/admin/artikels — buat artikel + upload foto
    public function store(Request $request)
    {
        $request->validate([
            'judul'        => 'required|string|max:255',
            'isi'          => 'required|string',
            'kategori'     => 'required|string',
            'is_published' => 'nullable|boolean',
            'ringkasan'    => 'nullable|string|max:300',
            'gambar'       => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'gambar_url'   => 'nullable|string|url', // alternatif pakai URL
        ]);

        // Handle upload foto
        $gambarPath = null;
        if ($request->hasFile('gambar')) {
            $gambarPath = $request->file('gambar')->store('artikels', 'public');
            $gambarPath = url('storage/' . $gambarPath);
        } elseif ($request->filled('gambar_url')) {
            $gambarPath = $request->gambar_url;
        }

        $artikel = Artikel::create([
            'admin_id'     => $request->user()->id,
            'judul'        => $request->judul,
            'isi'          => $request->isi,
            'kategori'     => $request->kategori,
            'ringkasan'    => $request->ringkasan ?? substr(strip_tags($request->isi), 0, 200),
            'gambar'       => $gambarPath,
            'is_published' => filter_var($request->is_published, FILTER_VALIDATE_BOOLEAN),
            'views'        => 0,
        ]);

        return response()->json([
            'success' => true,
            'message' => $artikel->is_published ? 'Artikel berhasil diterbitkan!' : 'Artikel disimpan sebagai draf.',
            'data'    => $this->_format($artikel->load('admin:id,nama,name')),
        ], 201);
    }

    // PUT /api/admin/artikels/{id}
    public function update(Request $request, $id)
    {
        $artikel = Artikel::findOrFail($id);

        $request->validate([
            'judul'        => 'sometimes|string|max:255',
            'isi'          => 'sometimes|string',
            'kategori'     => 'sometimes|string',
            'is_published' => 'nullable|boolean',
            'ringkasan'    => 'nullable|string|max:300',
            'gambar'       => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'gambar_url'   => 'nullable|string',
        ]);

        $data = $request->only(['judul', 'isi', 'kategori', 'ringkasan']);

        if ($request->has('is_published')) {
            $data['is_published'] = filter_var($request->is_published, FILTER_VALIDATE_BOOLEAN);
        }

        // Update foto
        if ($request->hasFile('gambar')) {
            // Hapus foto lama dari storage
            if ($artikel->gambar && str_contains($artikel->gambar, 'storage/')) {
                $oldPath = str_replace(url('storage/'), '', $artikel->gambar);
                Storage::disk('public')->delete($oldPath);
            }
            $path = $request->file('gambar')->store('artikels', 'public');
            $data['gambar'] = url('storage/' . $path);
        } elseif ($request->filled('gambar_url')) {
            $data['gambar'] = $request->gambar_url;
        }

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

    // DELETE /api/admin/artikels/{id}
    public function destroy(Request $request, $id)
    {
        $artikel = Artikel::findOrFail($id);

        // Hapus foto dari storage
        if ($artikel->gambar && str_contains($artikel->gambar, 'storage/')) {
            $oldPath = str_replace(url('storage/'), '', $artikel->gambar);
            Storage::disk('public')->delete($oldPath);
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
            'dura_baca'    => $this->_hitungDuraBaca($a->isi),
            'admin'        => $a->admin ? ($a->admin->nama ?? $a->admin->name) : 'Admin',
            'created_at'   => $a->created_at?->format('d M Y'),
            'updated_at'   => $a->updated_at?->format('d M Y'),
        ];
    }

    private function _hitungDuraBaca(string $isi): string
    {
        $wordCount = str_word_count(strip_tags($isi));
        $menit = max(1, round($wordCount / 200));
        return "$menit menit";
    }
}
