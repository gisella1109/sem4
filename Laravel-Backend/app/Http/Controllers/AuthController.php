<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    // LOGIN
    public function login(Request $req)
    {
        // ambil user berdasarkan email dulu
        $user = DB::table('users')
            ->where('email', $req->email)
            ->first();

        // cek user & password hash
        if ($user && Hash::check($req->password, $user->password)) {
            return response()->json([
                "status" => "success",
                "role" => $user->role,
                "nama" => $user->name
            ]);
        }

        return response()->json([
            "status" => "error"
        ]);
    }

    // REGISTER
    public function register(Request $req)
    {
        // cek email sudah ada atau belum
        $cek = DB::table('users')
            ->where('email', $req->email)
            ->first();

        if ($cek) {
            return response()->json([
                "status" => "email_sudah_ada"
            ]);
        }

        // insert user baru (password di-hash)
        DB::table('users')->insert([
            "name" => $req->nama,
            "email" => $req->email,
            "password" => Hash::make($req->password),
            "role" => "pasien"
        ]);

        return response()->json([
            "status" => "success"
        ]);
    }
}