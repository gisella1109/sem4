<?php
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\FoodController;
use App\Http\Controllers\Api\FoodLogController;
use App\Http\Controllers\Api\GulaDarahController;
use App\Http\Controllers\Api\ChatController;
use Illuminate\Support\Facades\Route;

// ==================== AUTH (Public) ====================
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login',    [AuthController::class, 'login']);

// ==================== Protected (Perlu Token) ====================
Route::middleware('auth:sanctum')->group(function () {

    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me',      [AuthController::class, 'me']);

    // Foods (read only - data dari seed)
    Route::get('/foods',        [FoodController::class, 'index']);
    Route::get('/foods/low-gi', [FoodController::class, 'lowGI']);
    Route::get('/foods/{id}',   [FoodController::class, 'show']);

    // Food Log
    Route::get('/food-logs',        [FoodLogController::class, 'index']);
    Route::post('/food-logs',       [FoodLogController::class, 'store']);
    Route::delete('/food-logs/{id}',[FoodLogController::class, 'destroy']);

    // Gula Darah
    Route::get('/gula-darah',        [GulaDarahController::class, 'index']);
    Route::post('/gula-darah',       [GulaDarahController::class, 'store']);
    Route::delete('/gula-darah/{id}',[GulaDarahController::class, 'destroy']);

    // Chat Komunitas
    Route::get('/users',                                  [ChatController::class, 'daftarUser']);
    Route::get('/chat/rooms',                             [ChatController::class, 'daftarRoom']);
    Route::post('/chat/rooms',                            [ChatController::class, 'bukaRoom']);
    Route::get('/chat/rooms/{roomId}/messages',           [ChatController::class, 'getPesan']);
    Route::post('/chat/rooms/{roomId}/messages',          [ChatController::class, 'kirimPesan']);
    Route::get('/chat/unread',                            [ChatController::class, 'totalBelumDibaca']);
});
