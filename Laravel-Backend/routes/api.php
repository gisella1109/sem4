<?php
use App\Http\Controllers\AuthController;
use App\Http\Controllers\FoodController;
use App\Http\Controllers\FoodLogController;
use App\Http\Controllers\GulaDarahController;
use App\Http\Controllers\ChatController;
use App\Http\Controllers\ArtikelController;
use Illuminate\Support\Facades\Route;

// ==================== PUBLIC (tanpa login) ====================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// Artikel publik — user bisa baca tanpa login
Route::get('/artikels',      [ArtikelController::class, 'index']);
Route::get('/artikels/{id}', [ArtikelController::class, 'show']);

// ==================== Protected (perlu token) ====================
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Foods
    Route::get('/foods',        [FoodController::class, 'index']);
    Route::get('/foods/low-gi', [FoodController::class, 'lowGI']);
    Route::get('/foods/{id}',   [FoodController::class, 'show']);

    // Food Log
    Route::get('/food-logs/summary', [FoodLogController::class, 'summary']);
    Route::get('/food-logs',         [FoodLogController::class, 'index']);
    Route::post('/food-logs',        [FoodLogController::class, 'store']);
    Route::delete('/food-logs/{id}', [FoodLogController::class, 'destroy']);

    // Gula Darah
    Route::get('/gula-darah',         [GulaDarahController::class, 'index']);
    Route::post('/gula-darah',        [GulaDarahController::class, 'store']);
    Route::delete('/gula-darah/{id}', [GulaDarahController::class, 'destroy']);

    // Artikel Admin — full CRUD
    Route::prefix('admin')->group(function () {
        Route::get('/artikels',         [ArtikelController::class, 'adminIndex']);
        Route::post('/artikels',        [ArtikelController::class, 'store']);
        Route::put('/artikels/{id}',    [ArtikelController::class, 'update']);
        Route::delete('/artikels/{id}', [ArtikelController::class, 'destroy']);
    });

    // Chat
    Route::get('/users',                         [ChatController::class, 'daftarUser']);
    Route::get('/chat/rooms',                    [ChatController::class, 'daftarRoom']);
    Route::post('/chat/rooms',                   [ChatController::class, 'bukaRoom']);
    Route::get('/chat/rooms/{roomId}/messages',  [ChatController::class, 'getPesan']);
    Route::post('/chat/rooms/{roomId}/messages', [ChatController::class, 'kirimPesan']);
    Route::get('/chat/unread',                   [ChatController::class, 'totalBelumDibaca']);
});