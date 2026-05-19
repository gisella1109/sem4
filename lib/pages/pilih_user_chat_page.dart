import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'chat_room_page.dart';

class PilihUserChatPage extends StatefulWidget {
  const PilihUserChatPage({super.key});

  @override
  State<PilihUserChatPage> createState() => _PilihUserChatPageState();
}

class _PilihUserChatPageState extends State<PilihUserChatPage> {
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final res = await ApiService.get('/users');
    if (res != null && res['success'] == true) {
      setState(() {
        _users = List<Map<String, dynamic>>.from(res['data']);
        _filtered = _users;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _users
          .where((u) => u['nama'].toString().toLowerCase().contains(q))
          .toList();
    });
  }

  String _inisial(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return nama.isNotEmpty ? nama[0].toUpperCase() : '?';
  }

  Future<void> _bukaChat(Map<String, dynamic> user) async {
    final res = await ApiService.post('/chat/rooms', {'target_user_id': user['id']});
    if (res != null && res['success'] == true) {
      final roomId = res['data']['room_id'] as int;
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomPage(roomId: roomId, nameLawan: user['nama']),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal membuka chat'), backgroundColor: Colors.redAccent),
      );
    }
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
        title: const Text('Pilih Pengguna',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Cari nama pengguna...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
                : _filtered.isEmpty
                    ? Center(
                        child: Text('Tidak ada pengguna ditemukan',
                            style: TextStyle(color: Colors.grey[500])),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filtered.length,
                        itemBuilder: (context, i) {
                          final user = _filtered[i];
                          final nama = user['nama']?.toString() ?? '';
                          final email = user['email']?.toString() ?? '';

                          return GestureDetector(
                            onTap: () => _bukaChat(user),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 46, height: 46,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2979FF).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(23),
                                      ),
                                      child: Center(
                                        child: Text(_inisial(nama),
                                            style: const TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2979FF))),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(nama,
                                              style: const TextStyle(
                                                  fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                                          const SizedBox(height: 2),
                                          Text(email,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chat_bubble_outline, color: Color(0xFF2979FF), size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
