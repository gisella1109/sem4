// ============================================================
// FILE: admin_artikel_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Tab 3 - Manajemen Artikel
// FUNGSI: Admin melihat daftar artikel dengan statistik total,
//         pembaca bulan ini, search, filter kategori, dan
//         setiap artikel ada tombol Edit & Hapus.
//         Tombol "Buat Artikel Baru" membuka AdminBuatArtikelPage.
// ============================================================

import 'package:flutter/material.dart';
import 'admin_buat_artikel_page.dart';

// ── Model artikel ─────────────────────────────────────────────
class DataArtikel {
  String judul;
  String kategori;
  String tanggal;
  int views;
  int komentar;
  bool diterbitkan;
  String isiSingkat;

  DataArtikel({
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.views,
    required this.komentar,
    required this.diterbitkan,
    required this.isiSingkat,
  });
}

class AdminArtikelPage extends StatefulWidget {
  const AdminArtikelPage({super.key});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final _cariCtrl = TextEditingController();
  String _filterKategori = 'Semua';

  final List<DataArtikel> _artikel = [
    DataArtikel(
      judul: 'Pentingnya Pemeriksaan Rutin Tekanan Darah di Usia Produktif',
      kategori: 'KESEHATAN JANTUNG',
      tanggal: 'Diterbitkan 12 Okt 2023',
      views: 1200,
      komentar: 8,
      diterbitkan: true,
      isiSingkat:
          'Penyakit kardiovaskular seringkali tidak menunjukkan gejala di tahap awal. Artikel ini...',
    ),
    DataArtikel(
      judul: 'Diet Seimbang untuk Penderita Diabetes Tipe 2: Panduan Lengkap',
      kategori: 'NUTRISI',
      tanggal: 'Diterbitkan 10 Okt 2023',
      views: 980,
      komentar: 5,
      diterbitkan: true,
      isiSingkat:
          'Mengatur pola makan yang tepat adalah kunci utama dalam mengelola diabetes tipe 2...',
    ),
    DataArtikel(
      judul: 'Olahraga Ringan yang Aman untuk Penderita Diabetes',
      kategori: 'GAYA HIDUP',
      tanggal: 'Draf — belum diterbitkan',
      views: 0,
      komentar: 0,
      diterbitkan: false,
      isiSingkat: 'Aktivitas fisik membantu mengontrol kadar gula darah secara alami...',
    ),
  ];

  final List<String> _kategoriList = [
    'Semua', 'KESEHATAN JANTUNG', 'NUTRISI', 'GAYA HIDUP', 'MEDIS',
  ];

  List<DataArtikel> get _filtered {
    return _artikel.where((a) {
      final cocokKategori =
          _filterKategori == 'Semua' || a.kategori == _filterKategori;
      final cocokCari = _cariCtrl.text.isEmpty ||
          a.judul.toLowerCase().contains(_cariCtrl.text.toLowerCase());
      return cocokKategori && cocokCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalDiterbitkan = _artikel.where((a) => a.diterbitkan).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Judul & deskripsi ───────────────────
                    const Text(
                      'Manajemen Artikel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2340),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kelola konten edukasi medis untuk pasien\ndan tenaga kesehatan dalam satu tempat.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78909C),
                          height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // ── Tombol buat artikel ─────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminBuatArtikelPage(
                              onSimpan: (artikel) =>
                                  setState(() => _artikel.insert(0, artikel)),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          '+ Buat Artikel Baru',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Statistik ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _kartuStatArtikel(
                            'Total Artikel Terbit',
                            '$totalDiterbitkan',
                            '+12% dari bulan lalu',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _kartuStatArtikel(
                            'Pembaca Bulan Ini',
                            '4.2k',
                            null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Search ──────────────────────────────
                    TextField(
                      controller: _cariCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari judul artikel atau kata kunci...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFB0BEC5), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFFB0BEC5), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Tombol Filter ───────────────────────
                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    // ── Daftar artikel ──────────────────────
                    ..._filtered.map((a) => _buildKartuArtikel(a)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Admin Log Medis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2340),
            ),
          ),
          Icon(Icons.notifications_none_rounded,
              color: Color(0xFF78909C), size: 24),
        ],
      ),
    );
  }

  Widget _kartuStatArtikel(String label, String nilai, String? sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF90A4AE))),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2340),
              height: 1,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF26A69A))),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              size: 18, color: Color(0xFF78909C)),
          const SizedBox(width: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _kategoriList.map((k) {
                final aktif = _filterKategori == k;
                return GestureDetector(
                  onTap: () => setState(() => _filterKategori = k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: aktif
                          ? const Color(0xFF1A73E8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: aktif
                            ? const Color(0xFF1A73E8)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: aktif
                            ? Colors.white
                            : const Color(0xFF78909C),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuArtikel(DataArtikel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
                a.kategori == 'NUTRISI'
                    ? Icons.restaurant_rounded
                    : a.kategori == 'GAYA HIDUP'
                        ? Icons.directions_run_rounded
                        : Icons.favorite_rounded,
                size: 48,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge kategori + tanggal
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.diterbitkan
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.kategori,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: a.diterbitkan
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFFE65100),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.tanggal,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF90A4AE)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Judul
                Text(
                  a.judul,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2340),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Isi singkat
                Text(
                  a.isiSingkat,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF78909C),
                      height: 1.4),
                ),
                const SizedBox(height: 10),

                // Stats + tombol edit/hapus
                Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${a.views >= 1000 ? '${(a.views / 1000).toStringAsFixed(1)}k' : a.views}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF90A4AE)),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 14, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      '${a.komentar}',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF90A4AE)),
                    ),
                    const Spacer(),

                    // Tombol Edit
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminBuatArtikelPage(
                            artikelEdit: a,
                            onSimpan: (updated) => setState(() {
                              final i = _artikel.indexOf(a);
                              if (i != -1) _artikel[i] = updated;
                            }),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 12, color: Color(0xFF1A73E8)),
                            SizedBox(width: 4),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A73E8))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Hapus
                    GestureDetector(
                      onTap: () => _konfirmasiHapus(a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                size: 12, color: Color(0xFFE53935)),
                            SizedBox(width: 4),
                            Text('Hapus',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE53935))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(DataArtikel a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Artikel?'),
        content: Text('Artikel "${a.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _artikel.remove(a));
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}