<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Artikel;

class ArtikelController extends Controller
{
    public function index()
    {
        return response()->json(Artikel::latest()->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required',
            'isi' => 'required',
            'gambar' => 'nullable'
        ]);

        $artikel = Artikel::create($request->all());

        return response()->json($artikel, 201);
    }
}