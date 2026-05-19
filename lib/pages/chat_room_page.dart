import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ChatRoomPage extends StatefulWidget {
  final int roomId;
  final String nameLawan;

  const ChatRoomPage({super.key, required this.roomId, required this.nameLawan});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final List<Map<String, dynamic>> _pesan = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _isLoading = true;
  bool _isSending = false;
  int _userId = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadUserId().then((_) {
      _loadPesan();
      // Polling setiap 3 detik untuk pesan baru (sederhana tanpa WebSocket)
      _timer = Timer.periodic(const Duration(seconds: 3), (_) => _loadPesan(scroll: false));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getInt('user_id') ?? 0;
  }

  Future<void> _loadPesan({bool scroll = true}) async {
    final res = await ApiService.get('/chat/rooms/${widget.roomId}/messages');
    if (res != null && res['success'] == true) {
      final baru = List<Map<String, dynamic>>.from(res['data']);
      if (mounted) {
        setState(() {
          _pesan.clear();
          _pesan.addAll(baru);
          _isLoading = false;
        });
        if (scroll && _pesan.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollKeBawah());
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _kirimPesan() async {
    final teks = _inputCtrl.text.trim();
    if (teks.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _inputCtrl.clear();

    // Tampilkan dulu secara optimistic
    final pesanSementara = {
      'id': -1,
      'sender_id': _userId,
      'pesan': teks,
      'created_at': DateTime.now().toIso8601String(),
      'sender': {'id': _userId, 'nama': 'Kamu'},
    };
    setState(() => _pesan.add(pesanSementara));
    _scrollKeBawah();

    final res = await ApiService.post(
      '/chat/rooms/${widget.roomId}/messages',
      {'pesan': teks},
    );

    setState(() => _isSending = false);

    if (res != null && res['success'] == true) {
      // Refresh untuk dapat ID pesan yang benar
      await _loadPesan(scroll: false);
    } else {
      // Hapus pesan sementara kalau gagal
      setState(() => _pesan.removeLast());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengirim pesan'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  void _scrollKeBawah() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatWaktu(String? waktu) {
    if (waktu == null) return '';
    try {
      final dt = DateTime.parse(waktu).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _formatTanggal(String? waktu) {
    if (waktu == null) return '';
    try {
      final dt = DateTime.parse(waktu).toLocal();
      final now = DateTime.now();
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day) return 'Hari ini';
      if (dt.year == now.year && dt.month == now.month && dt.day == now.day - 1) return 'Kemarin';
      return DateFormat('dd MMMM yyyy', 'id_ID').format(dt);
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
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(_inisial(widget.nameLawan),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.nameLawan,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
                : _pesan.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('👋', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 12),
                            Text('Mulai percakapan dengan ${widget.nameLawan}',
                                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        itemCount: _pesan.length,
                        itemBuilder: (context, i) {
                          final msg = _pesan[i];
                          final isMe = (msg['sender_id'] as num?)?.toInt() == _userId;

                          // Tampilkan pemisah tanggal jika beda hari
                          bool tampilTanggal = false;
                          if (i == 0) {
                            tampilTanggal = true;
                          } else {
                            final prevDate = _pesan[i - 1]['created_at']?.toString().substring(0, 10);
                            final curDate = msg['created_at']?.toString().substring(0, 10);
                            tampilTanggal = prevDate != curDate;
                          }

                          return Column(
                            children: [
                              if (tampilTanggal)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _formatTanggal(msg['created_at']?.toString()),
                                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              _buildBubble(msg, isMe),
                            ],
                          );
                        },
                      ),
          ),

          // Input area
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _inputCtrl,
                      maxLines: null,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _kirimPesan(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _kirimPesan,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _isSending ? Colors.grey : const Color(0xFF2979FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 4,
          left: isMe ? 60 : 0,
          right: isMe ? 0 : 60,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2979FF) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['pesan']?.toString() ?? '',
              style: TextStyle(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF1A1A2E), height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              _formatWaktu(msg['created_at']?.toString()),
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
