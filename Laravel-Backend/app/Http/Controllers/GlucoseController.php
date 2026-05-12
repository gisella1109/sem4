<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class GlucoseController extends Controller
{
    public function get()
    {
        return DB::table('glucose')->orderBy('waktu','desc')->get();
    }

    public function tambah(Request $req)
    {
        DB::table('glucose')->insert([
            "nilai" => $req->nilai,
            "waktu" => $req->waktu,
            "konteks_makan" => $req->konteks_makan,
            "catatan" => $req->catatan
        ]);

        return response()->json(["status"=>"success"]);
    }

    public function delete(Request $req)
    {
        DB::table('glucose')->where('id',$req->id)->delete();
        return response()->json(["status"=>"deleted"]);
    }
}