import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'chat_room_page.dart';
import 'pilih_user_chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> _rooms = [];
  bool _isLoading = true;
  int _userId = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    _loadRooms();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _userId = prefs.getInt('user_id') ?? 0);
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    final res = await ApiService.get('/chat/rooms');
    if (res != null && res['success'] == true) {
      setState(() {
        _rooms = List<Map<String, dynamic>>.from(res['data']);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  String _formatWaktu(String? waktu) {
    if (waktu == null) return '';
    try {
      final dt = DateTime.parse(waktu).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
        return DateFormat('HH:mm').format(dt);
      } else if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1) {
        return 'Kemarin';
      }
      return DateFormat('dd/MM').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _inisial(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Komunitas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2979FF)),
            onPressed: _loadRooms,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2979FF),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PilihUserChatPage()),
          );
          _loadRooms(); // refresh setelah balik
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : _rooms.isEmpty
              ? _buildKosong()
              : RefreshIndicator(
                  onRefresh: _loadRooms,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _rooms.length,
                    itemBuilder: (context, i) => _buildItemRoom(_rooms[i]),
                  ),
                ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada percakapan',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tekan tombol + untuk mulai chat',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildItemRoom(Map<String, dynamic> room) {
    final lawan = room['lawan_bicara'] as Map<String, dynamic>? ?? {};
    final nama = lawan['nama']?.toString() ?? 'Pengguna';
    final pesanTerakhir = room['pesan_terakhir']?.toString() ?? 'Belum ada pesan';
    final waktu = _formatWaktu(room['waktu_terakhir']?.toString());
    final belumDibaca = (room['belum_dibaca'] as num?)?.toInt() ?? 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              roomId: room['room_id'],
              nameLawan: nama,
            ),
          ),
        );
        _loadRooms();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(_inisial(nama),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(nama,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        ),
                        Text(waktu, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pesanTerakhir,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: belumDibaca > 0 ? const Color(0xFF1A1A2E) : Colors.grey[500],
                              fontWeight: belumDibaca > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (belumDibaca > 0)
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Color(0xFF2979FF),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              belumDibaca > 99 ? '99+' : '$belumDibaca',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
