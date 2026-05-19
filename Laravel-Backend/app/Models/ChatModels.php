<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class ChatRoom extends Model
{
    protected $fillable = ['user1_id', 'user2_id', 'last_message_at'];

    public function user1() {
        return $this->belongsTo(User::class, 'user1_id');
    }
    public function user2() {
        return $this->belongsTo(User::class, 'user2_id');
    }
    public function pesan() {
        return $this->hasMany(ChatMessage::class, 'room_id');
    }
    public function pesanTerakhir() {
        return $this->hasOne(ChatMessage::class, 'room_id')->latestOfMany();
    }
}

class ChatMessage extends Model
{
    protected $fillable = ['room_id', 'sender_id', 'pesan', 'sudah_dibaca'];

    public function sender() {
        return $this->belongsTo(User::class, 'sender_id');
    }
    public function room() {
        return $this->belongsTo(ChatRoom::class, 'room_id');
    }
}
