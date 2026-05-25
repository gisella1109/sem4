<?php
namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\ChatRoom;
use App\Models\ChatMessage;
use App\Models\User;
use Illuminate\Http\Request;

class ChatController extends Controller
{
    // GET /api/users — daftar semua user (untuk dipilih diajak chat)
    public function daftarUser(Request $request)
    {
        $users = User::where('id', '!=', $request->user()->id)
            ->select('id', 'nama', 'email', 'role')
            ->orderBy('nama')
            ->get();

        return response()->json(['success' => true, 'data' => $users]);
    }

    // GET /api/chat/rooms — daftar room chat user ini
    public function daftarRoom(Request $request)
    {
        $userId = $request->user()->id;

        $rooms = ChatRoom::where('user1_id', $userId)
            ->orWhere('user2_id', $userId)
            ->with([
                'user1:id,nama,email',
                'user2:id,nama,email',
                'pesanTerakhir',
            ])
            ->orderByDesc('last_message_at')
            ->get()
            ->map(function ($room) use ($userId) {
                // Tentukan lawan bicara
                $lawan = $room->user1_id == $userId ? $room->user2 : $room->user1;
                $pesanTerakhir = $room->pesanTerakhir;

                // Hitung pesan belum dibaca
                $belumDibaca = ChatMessage::where('room_id', $room->id)
                    ->where('sender_id', '!=', $userId)
                    ->where('sudah_dibaca', false)
                    ->count();

                return [
                    'room_id'        => $room->id,
                    'lawan_bicara'   => $lawan,
                    'pesan_terakhir' => $pesanTerakhir?->pesan,
                    'waktu_terakhir' => $pesanTerakhir?->created_at,
                    'belum_dibaca'   => $belumDibaca,
                ];
            });

        return response()->json(['success' => true, 'data' => $rooms]);
    }

    // POST /api/chat/rooms — buat/buka room chat dengan user lain
    public function bukaRoom(Request $request)
    {
        $request->validate(['target_user_id' => 'required|exists:users,id']);

        $userId   = $request->user()->id;
        $targetId = $request->target_user_id;

        if ($userId == $targetId) {
            return response()->json(['success' => false, 'message' => 'Tidak bisa chat dengan diri sendiri'], 422);
        }

        // Pastikan urutan konsisten (user1 < user2)
        $u1 = min($userId, $targetId);
        $u2 = max($userId, $targetId);

        $room = ChatRoom::firstOrCreate(
            ['user1_id' => $u1, 'user2_id' => $u2],
            ['last_message_at' => now()]
        );

        return response()->json(['success' => true, 'data' => ['room_id' => $room->id]]);
    }

    // GET /api/chat/rooms/{roomId}/messages — ambil pesan di room
    public function getPesan(Request $request, $roomId)
    {
        $userId = $request->user()->id;
        $room   = ChatRoom::findOrFail($roomId);

        // Pastikan user adalah anggota room
        if ($room->user1_id != $userId && $room->user2_id != $userId) {
            return response()->json(['success' => false, 'message' => 'Tidak punya akses'], 403);
        }

        $pesan = ChatMessage::where('room_id', $roomId)
            ->with('sender:id,nama')
            ->orderBy('created_at')
            ->get();

        // Tandai pesan sebagai sudah dibaca
        ChatMessage::where('room_id', $roomId)
            ->where('sender_id', '!=', $userId)
            ->where('sudah_dibaca', false)
            ->update(['sudah_dibaca' => true]);

        return response()->json(['success' => true, 'data' => $pesan]);
    }

    // POST /api/chat/rooms/{roomId}/messages — kirim pesan
    public function kirimPesan(Request $request, $roomId)
    {
        $request->validate(['pesan' => 'required|string|max:1000']);

        $userId = $request->user()->id;
        $room   = ChatRoom::findOrFail($roomId);

        if ($room->user1_id != $userId && $room->user2_id != $userId) {
            return response()->json(['success' => false, 'message' => 'Tidak punya akses'], 403);
        }

        $msg = ChatMessage::create([
            'room_id'   => $roomId,
            'sender_id' => $userId,
            'pesan'     => $request->pesan,
        ]);

        // Update waktu pesan terakhir di room
        $room->update(['last_message_at' => now()]);

        return response()->json([
            'success' => true,
            'data'    => $msg->load('sender:id,nama'),
        ], 201);
    }

    // GET /api/chat/unread — total pesan belum dibaca
    public function totalBelumDibaca(Request $request)
    {
        $userId = $request->user()->id;

        $roomIds = ChatRoom::where('user1_id', $userId)
            ->orWhere('user2_id', $userId)
            ->pluck('id');

        $total = ChatMessage::whereIn('room_id', $roomIds)
            ->where('sender_id', '!=', $userId)
            ->where('sudah_dibaca', false)
            ->count();

        return response()->json(['success' => true, 'total' => $total]);
    }
}