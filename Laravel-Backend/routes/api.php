<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\GlucoseController;
use App\Http\Controllers\MedicationController;
use App\Http\Controllers\ArtikelController;
use App\Http\Controllers\OTPController;

// TEST (biar cek jalan)
Route::get('/test', function () {
    return "API jalan";
});

// AUTH
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// GLUCOSE
Route::get('/glucose', [GlucoseController::class, 'get']);
Route::post('/glucose', [GlucoseController::class, 'tambah']);
Route::post('/glucose/delete', [GlucoseController::class, 'delete']);

// MEDICATION
Route::get('/medication', [MedicationController::class, 'get']);
Route::post('/medication', [MedicationController::class, 'tambah']);
Route::post('/medication/delete', [MedicationController::class, 'delete']);

//  ARTIKEL
Route::get('/artikel', [ArtikelController::class, 'index']);
Route::post('/artikel', [ArtikelController::class, 'store']);

// OTP
Route::post('/send-otp', [OTPController::class, 'sendOTP']);
Route::post('/verify-otp', [OTPController::class, 'verifyOTP']);