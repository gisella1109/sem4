<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class OTPController extends Controller
{
    // 1. Fungsi Kirim OTP
    public function sendOTP(Request $request) 
    {
        $request->validate([
            'email' => 'required|email'
        ]);

        $email = $request->email;
        $otp = rand(100000, 999999); // Generate 6 digit angka

        // Simpan atau update OTP di database
        // Kita simpan created_at untuk cek masa berlaku (misal 5 menit)
        DB::table('otps')->updateOrInsert(
      ['email' => $email],
      [
        'otp' => $otp,
        'expired_at' => Carbon::now()->addMinutes(5),
        'created_at' => Carbon::now(),
        'updated_at' => Carbon::now(),
       ]
      );

        // Kirim Email
        try {
            Mail::raw("Kode OTP verifikasi Anda adalah: $otp. Kode ini berlaku selama 5 menit.", function ($message) use ($email) {
                $message->to($email)->subject("Kode Verifikasi OTP");
            });

            return response()->json([
                'status' => 'success',
                'message' => 'OTP berhasil dikirim ke ' . $email
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengirim email: ' . $e->getMessage()
            ], 500);
        }
    }

    // 2. Fungsi Verifikasi OTP (Dipanggil saat user input kode di Flutter)
    public function verifyOTP(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'otp' => 'required|numeric'
        ]);

        $data = DB::table('otps')
            ->where('email', $request->email)
            ->where('otp', $request->otp)
            ->first();

        if (!$data) {
            return response()->json(['message' => 'Kode OTP salah!'], 400);
        }

        // Cek kadaluwarsa (Contoh: 5 menit)
        $isExpired = Carbon::now()->gt(Carbon::parse($data->expired_at));
        
        if ($isExpired) {
            return response()->json(['message' => 'OTP sudah kadaluwarsa, silakan minta baru.'], 400);
        }

        // Jika berhasil, hapus OTP agar tidak bisa dipakai lagi
        DB::table('otps')->where('email', $request->email)->delete();

        return response()->json([
            'status' => 'success',
            'message' => 'Verifikasi berhasil!'
        ], 200);
    }
}