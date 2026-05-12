<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class MedicationController extends Controller
{
    public function get()
    {
        return DB::table('medication')->orderBy('dibuat_pada','desc')->get();
    }

    public function tambah(Request $req)
    {
        DB::table('medication')->insert([
            "nama_obat"=>$req->nama_obat,
            "dosis"=>$req->dosis,
            "frekuensi"=>$req->frekuensi,
            "waktu_konsumsi"=>$req->waktu_konsumsi,
            "tipe"=>$req->tipe,
            "catatan"=>$req->catatan
        ]);

        return response()->json(["status"=>"success"]);
    }

    public function delete(Request $req)
    {
        DB::table('medication')->where('id',$req->id)->delete();
        return response()->json(["status"=>"deleted"]);
    }
}