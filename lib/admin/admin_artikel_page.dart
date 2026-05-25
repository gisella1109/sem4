import 'package:flutter/material.dart';
import '../models/artikel_model.dart';
import '../services/artikel_service.dart';
import 'admin_buat_artikel_page.dart';

class AdminArtikelPage extends StatefulWidget {
  const AdminArtikelPage({super.key});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final _cariCtrl = TextEditingController();
  String _filterKategori = 'Semua';
  bool _loading = true;

  List<Artikel> _artikel = [];
  int _totalTerbit = 0;
  int _totalDraf   = 0;
  int _totalViews  = 0;

  final List<String> _kategoriList = ['Semua', 'Dasar', 'Nutrisi', 'Monitoring', 'Gaya Hidup'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await ArtikelService.fetchAdminArtikel(
      kategori: _filterKategori,
      q: _cariCtrl.text,
    );
    setState(() {
      _artikel     = result['artikels'] as List<Artikel>;
      _totalTerbit = result['total_terbit'] as int;
      _totalDraf   = result['total_draf'] as int;
      _totalViews  = result['total_views'] as int;
      _loading     = false;
    });
  }

  Future<void> _hapus(Artikel a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Artikel?'),
        content: Text('Artikel "${a.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context, true),  child: const Text('Hapus', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (ok != true) return;
    final berhasil = await ArtikelService.hapusArtikel(a.id);
    if (berhasil && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Artikel dihapus'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating));
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manajemen Artikel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1A2340))),
                  IconButton(icon: const Icon(Icons.refresh_rounded, color: Color(0xFF78909C)), onPressed: _load),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistik
                            Row(children: [
                              Expanded(child: _kartuStat('Total Terbit', '$_totalTerbit', const Color(0xFF1A73E8))),
                              const SizedBox(width: 10),
                              Expanded(child: _kartuStat('Total Draf', '$_totalDraf', Colors.orange)),
                              const SizedBox(width: 10),
                              Expanded(child: _kartuStat('Total Views', _totalViews >= 1000 ? '${(_totalViews/1000).toStringAsFixed(1)}k' : '$_totalViews', Colors.green)),
                            ]),
                            const SizedBox(height: 16),

                            // Tombol buat
                            SizedBox(
                              width: double.infinity, height: 46,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminBuatArtikelPage()));
                                  _load();
                                },
                                icon: const Icon(Icons.add_rounded, size: 18),
                                label: const Text('+ Buat Artikel Baru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Search
                            TextField(
                              controller: _cariCtrl,
                              onChanged: (_) => _load(),
                              decoration: InputDecoration(
                                hintText: 'Cari judul artikel...',
                                hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFFB0BEC5), size: 20),
                                filled: true, fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                                contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Filter chips
                            SizedBox(
                              height: 34,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: _kategoriList.map((k) {
                                  final aktif = _filterKategori == k;
                                  return GestureDetector(
                                    onTap: () { setState(() => _filterKategori = k); _load(); },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: aktif ? const Color(0xFF1A73E8) : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: aktif ? const Color(0xFF1A73E8) : Colors.grey.shade300),
                                      ),
                                      child: Text(k, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: aktif ? Colors.white : const Color(0xFF78909C))),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (_artikel.isEmpty)
                              const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('Belum ada artikel', style: TextStyle(color: Color(0xFF90A4AE)))))
                            else
                              ..._artikel.map((a) => _buildKartu(a)),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kartuStat(String label, String nilai, Color warna) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
        const SizedBox(height: 4),
        Text(nilai, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: warna, height: 1)),
      ]),
    );
  }

  Widget _buildKartu(Artikel a) {
    final terbit = a.isPublished;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header gambar
          Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: terbit ? [const Color(0xFF1565C0), const Color(0xFF42A5F5)] : [Colors.grey.shade400, Colors.grey.shade300],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Center(child: Icon(
              a.kategori == 'Nutrisi' ? Icons.restaurant_rounded : a.kategori == 'Gaya Hidup' ? Icons.directions_run_rounded : a.kategori == 'Monitoring' ? Icons.monitor_heart_rounded : Icons.menu_book_rounded,
              size: 40, color: Colors.white.withOpacity(0.6),
            )),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge status + kategori
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: terbit ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(6)),
                    child: Text(terbit ? 'TERBIT' : 'DRAF', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: terbit ? Colors.green : Colors.orange)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                    child: Text(a.kategori, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF1A73E8))),
                  ),
                  const Spacer(),
                  Text(a.createdAt, style: const TextStyle(fontSize: 10, color: Color(0xFF90A4AE))),
                ]),
                const SizedBox(height: 8),
                Text(a.judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A2340), height: 1.4)),
                const SizedBox(height: 4),
                Text(a.ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF78909C), height: 1.4)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text('${a.views}', style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))),
                  const SizedBox(width: 8),
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
                  const SizedBox(width: 4),
                  Text(a.duraBaca, style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))),
                  const Spacer(),
                  // Tombol Edit
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => AdminBuatArtikelPage(artikelEdit: a)));
                      _load();
                    },
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(6)),
                      child: const Row(children: [Icon(Icons.edit_rounded, size: 12, color: Color(0xFF1A73E8)), SizedBox(width: 4), Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1A73E8)))])),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Hapus
                  GestureDetector(
                    onTap: () => _hapus(a),
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6)),
                      child: const Row(children: [Icon(Icons.delete_rounded, size: 12, color: Color(0xFFE53935)), SizedBox(width: 4), Text('Hapus', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFE53935)))])),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
