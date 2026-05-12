import 'package:flutter/material.dart';
import '../models/glucose_store.dart';
import '../models/glucose_entry.dart';
import '../models/artikel_model.dart';
import 'health_profile_page.dart';
import 'rewards_page.dart';
import 'edit_profile_page.dart';
import 'blood_sugar_analysis_page.dart';
import 'food_photo_input_page.dart';
import 'meal_history_page.dart';
import 'add_glucose_page.dart';
import 'glucose_history_page.dart';
import 'insulin_tracker_page.dart';
import 'notifikasi_page.dart';
import 'manual_food_log_page.dart';
import 'artikel_edukasi_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _indeksAktif = 0;
  int _indeksTips = 0;
  final PageController _tipsController = PageController();
  final List<double> _dataGlukosa = [90, 105, 98, 115, 108, 120, 110];

  final _glucoseStore = GlucoseStore();

  // Ambil kondisi gula darah terbaru
  _KondisiGula get _kondisiGula {
    final entri = _glucoseStore.semuaEntri;
    if (entri.isEmpty) return _KondisiGula.normal;
    final terbaru = entri.first.nilai;
    if (terbaru < 70) return _KondisiGula.rendah;
    if (terbaru <= 100) return _KondisiGula.normal;
    if (terbaru <= 180) return _KondisiGula.tinggi;
    return _KondisiGula.sangatTinggi;
  }

  GlucoseEntry? get _entriTerbaru {
    final entri = _glucoseStore.semuaEntri;
    return entri.isNotEmpty ? entri.first : null;
  }

  List<Map<String, dynamic>> get _daftarTips {
    switch (_kondisiGula) {
      case _KondisiGula.rendah:
        return [
          {
            'kategori': '⚠️ Gula Darah Rendah',
            'ikon': Icons.warning_amber_rounded,
            'warna': [Color(0xFFF57F17), Color(0xFFFFA000)],
            'isi': 'Gula darah Anda rendah (${_entriTerbaru?.nilai.toStringAsFixed(0) ?? '-'} mg/dL). Segera konsumsi makanan/minuman manis dan istirahat.',
          },
          {
            'kategori': '🍽️ Makanan yang Dianjurkan',
            'ikon': Icons.restaurant_menu,
            'warna': [Color(0xFF43A047), Color(0xFF66BB6A)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Jus buah murni / madu', 'alasan': 'Naikkan gula darah dengan cepat'},
              {'nama': 'Pisang atau kurma', 'alasan': 'Gula alami yang mudah diserap'},
              {'nama': 'Roti gandum dengan selai', 'alasan': 'Energi cepat + tahan lama'},
              {'nama': 'Susu full cream', 'alasan': 'Karbohidrat + protein seimbang'},
              {'nama': 'Biskuit asin', 'alasan': 'Karbohidrat simpel untuk darurat'},
            ],
            'mode': 'anjuran',
          },
          {
            'kategori': '🏃 Olahraga Hari Ini',
            'ikon': Icons.self_improvement,
            'warna': [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Hindari olahraga berat', 'durasi': 'Sementara waktu', 'ikon': Icons.block},
              {'nama': 'Stretching ringan', 'durasi': '5–10 menit', 'ikon': Icons.accessibility_new},
              {'nama': 'Istirahat cukup', 'durasi': 'Prioritas utama', 'ikon': Icons.hotel},
              {'nama': 'Jalan santai', 'durasi': 'Setelah makan', 'ikon': Icons.directions_walk},
            ],
          },
        ];

      case _KondisiGula.normal:
        return [
          {
            'kategori': '✅ Gula Darah Normal',
            'ikon': Icons.check_circle_outline,
            'warna': [Color(0xFF2979FF), Color(0xFF448AFF)],
            'isi': 'Gula darah Anda normal (${_entriTerbaru?.nilai.toStringAsFixed(0) ?? '-'} mg/dL). Pertahankan pola makan dan gaya hidup sehat Anda!',
          },
          {
            'kategori': '🚫 Makanan yang Dihindari',
            'ikon': Icons.no_food_outlined,
            'warna': [Color(0xFFE53935), Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Minuman bersoda & jus kemasan', 'alasan': 'Tinggi gula tambahan'},
              {'nama': 'Kue manis & permen', 'alasan': 'Gula sederhana berlebih'},
              {'nama': 'Gorengan berminyak', 'alasan': 'Meningkatkan resistensi insulin'},
              {'nama': 'Nasi putih porsi besar', 'alasan': 'Indeks glikemik tinggi'},
              {'nama': 'Makanan olahan/cepat saji', 'alasan': 'Tinggi gula & sodium tersembunyi'},
            ],
          },
          {
            'kategori': '🏃 Rekomendasi Olahraga',
            'ikon': Icons.directions_run_rounded,
            'warna': [Color(0xFF00897B), Color(0xFF26A69A)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki', 'durasi': '30 menit/hari', 'ikon': Icons.directions_walk},
              {'nama': 'Senam ringan', 'durasi': '20 menit pagi', 'ikon': Icons.self_improvement},
              {'nama': 'Bersepeda santai', 'durasi': '30 menit, 3×/minggu', 'ikon': Icons.pedal_bike_outlined},
              {'nama': 'Renang', 'durasi': '30 menit, 2×/minggu', 'ikon': Icons.pool_outlined},
              {'nama': 'Yoga & stretching', 'durasi': '15–20 menit/hari', 'ikon': Icons.accessibility_new},
            ],
          },
        ];

      case _KondisiGula.tinggi:
        return [
          {
            'kategori': '⚠️ Gula Darah Tinggi',
            'ikon': Icons.trending_up_rounded,
            'warna': [Color(0xFFF4511E), Color(0xFFFF7043)],
            'isi': 'Gula darah Anda tinggi (${_entriTerbaru?.nilai.toStringAsFixed(0) ?? '-'} mg/dL). Kurangi karbohidrat hari ini dan perbanyak gerak.',
          },
          {
            'kategori': '🚫 Hindari Sekarang',
            'ikon': Icons.no_food_outlined,
            'warna': [Color(0xFFE53935), Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Nasi, roti, mie putih', 'alasan': 'Langsung naikkan gula darah'},
              {'nama': 'Minuman manis & boba', 'alasan': 'Gula cair terserap sangat cepat'},
              {'nama': 'Buah manis (mangga, durian)', 'alasan': 'Fruktosa tinggi'},
              {'nama': 'Gorengan & fast food', 'alasan': 'Lemak trans memperparah kondisi'},
              {'nama': 'Kecap & saus manis', 'alasan': 'Gula tersembunyi tinggi'},
            ],
          },
          {
            'kategori': '🏃 Olahraga Turunkan Gula',
            'ikon': Icons.directions_run_rounded,
            'warna': [Color(0xFF00897B), Color(0xFF26A69A)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki cepat', 'durasi': '30–45 menit', 'ikon': Icons.directions_walk},
              {'nama': 'Senam aerobik', 'durasi': '30 menit', 'ikon': Icons.self_improvement},
              {'nama': 'Bersepeda', 'durasi': '30 menit', 'ikon': Icons.pedal_bike_outlined},
              {'nama': 'Naik turun tangga', 'durasi': '10–15 menit', 'ikon': Icons.stairs},
              {'nama': 'Yoga aktif', 'durasi': '20 menit', 'ikon': Icons.accessibility_new},
            ],
          },
        ];

      case _KondisiGula.sangatTinggi:
        return [
          {
            'kategori': '🚨 Gula Darah Sangat Tinggi',
            'ikon': Icons.emergency_rounded,
            'warna': [Color(0xFFB71C1C), Color(0xFFD32F2F)],
            'isi': 'Gula darah Anda ${_entriTerbaru?.nilai.toStringAsFixed(0) ?? '-'} mg/dL — sangat tinggi! Segera konsultasikan ke dokter dan minum air putih yang banyak.',
          },
          {
            'kategori': '🚫 HINDARI Semua Ini',
            'ikon': Icons.no_food_outlined,
            'warna': [Color(0xFFE53935), Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Semua makanan manis', 'alasan': 'Berbahaya untuk kondisi ini'},
              {'nama': 'Karbohidrat sederhana', 'alasan': 'Nasi, roti, mie — batasi ketat'},
              {'nama': 'Minuman bergula', 'alasan': 'Termasuk jus & susu kental manis'},
              {'nama': 'Alkohol', 'alasan': 'Sangat berbahaya saat gula tinggi'},
              {'nama': 'Makanan tinggi garam', 'alasan': 'Memperburuk tekanan darah'},
            ],
          },
          {
            'kategori': '🏃 Olahraga Ringan Saja',
            'ikon': Icons.directions_walk,
            'warna': [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki santai', 'durasi': '15–20 menit', 'ikon': Icons.directions_walk},
              {'nama': 'Stretching pelan', 'durasi': '10 menit', 'ikon': Icons.accessibility_new},
              {'nama': 'Hindari olahraga berat', 'durasi': 'Berbahaya saat ini', 'ikon': Icons.block},
              {'nama': 'Perbanyak minum air', 'durasi': '8+ gelas/hari', 'ikon': Icons.water_drop_outlined},
            ],
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildKartuGlukosa(),
                  const SizedBox(height: 20),
                  _buildAksiCepat(),
                  const SizedBox(height: 20),
                  _buildTipsHarian(),
                  const SizedBox(height: 20),
                  _buildEdukasi(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: _buildNavBawah(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, color: Color(0xFF2979FF), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Senin, 24 Okt', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const Text('Selamat pagi, Alex', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                ],
              ),
            ],
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 26),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
                color: const Color(0xFF1A1A2E),
              ),
              Positioned(
                right: 10, top: 10,
                child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKartuGlukosa() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kadar Gula Darah', style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.arrow_forward, size: 13, color: Colors.green),
                    SizedBox(width: 4),
                    Text('Normal', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('110', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('mg/dL', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGrafikBatang(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RATA-RATA 7 HARI', style: TextStyle(fontSize: 10, color: Colors.grey[400], letterSpacing: 1, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    const Text('108 mg/dL', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlucoseHistoryPage())),
                  child: const Text('Lihat Detail', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrafikBatang() {
    final double nilaiMaks = _dataGlukosa.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 80,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_dataGlukosa.length, (i) {
          final hariIni = i == _dataGlukosa.length - 1;
          final tinggi = (_dataGlukosa[i] / nilaiMaks) * 70;
          return AnimatedContainer(
            duration: Duration(milliseconds: 400 + i * 80),
            width: 28, height: tinggi,
            decoration: BoxDecoration(
              color: hariIni ? const Color(0xFF2979FF) : const Color(0xFFBBDEFB),
              borderRadius: BorderRadius.circular(6),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAksiCepat() {
    final daftarAksi = [
      {'ikon': Icons.water_drop_outlined, 'warna': const Color(0xFF2979FF), 'bg': const Color(0xFFE3F2FD), 'judul': 'Catat Gula Darah', 'subjudul': 'Entri terakhir: 2 jam lalu', 'halaman': const AddGlucosePage()},
      {'ikon': Icons.vaccines_outlined, 'warna': const Color(0xFF00BFA5), 'bg': const Color(0xFFE0F2F1), 'judul': 'Pelacak Insulin', 'subjudul': '8 unit menunggu untuk makan malam', 'halaman': const InsulinTrackerPage()},
      {'ikon': Icons.edit_note_outlined, 'warna': const Color(0xFFFF7043), 'bg': const Color(0xFFFBE9E7), 'judul': 'Catat Makanan Manual', 'subjudul': 'Input makanan tanpa foto', 'halaman': const CatatanMakananManualPage()},
      {'ikon': Icons.emoji_events_outlined, 'warna': const Color(0xFFFFB300), 'bg': const Color(0xFFFFF8E1), 'judul': 'Hadiah & Poin', 'subjudul': '750/1000 poin • Level 5', 'halaman': const RewardsPage()},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Aksi Cepat', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...daftarAksi.map((aksi) => _buildKartuAksi(aksi)),
        ],
      ),
    );
  }

  Widget _buildKartuAksi(Map<String, dynamic> aksi) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: aksi['bg'] as Color, borderRadius: BorderRadius.circular(12)),
          child: Icon(aksi['ikon'] as IconData, color: aksi['warna'] as Color, size: 22),
        ),
        title: Text(aksi['judul'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A2E))),
        subtitle: Text(aksi['subjudul'] as String, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => aksi['halaman'] as Widget)),
      ),
    );
  }

  Widget _buildTipsHarian() {
    final kondisi = _kondisiGula;
    final badgeWarna = kondisi == _KondisiGula.rendah
        ? const Color(0xFFF57F17)
        : kondisi == _KondisiGula.normal
            ? const Color(0xFF2979FF)
            : kondisi == _KondisiGula.tinggi
                ? const Color(0xFFF4511E)
                : const Color(0xFFB71C1C);
    final badgeTeks = kondisi == _KondisiGula.rendah
        ? '🔻 Rendah'
        : kondisi == _KondisiGula.normal
            ? '✅ Normal'
            : kondisi == _KondisiGula.tinggi
                ? '🔺 Tinggi'
                : '🚨 Kritis';
    final tips = _daftarTips;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header dengan badge kondisi
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text('Panduan Hari Ini',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              const SizedBox(width: 8),
              if (_entriTerbaru != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeWarna.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeWarna.withValues(alpha: 0.4)),
                  ),
                  child: Text('$badgeTeks  ${_entriTerbaru!.nilai.toStringAsFixed(0)} mg/dL',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: badgeWarna)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Tab selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: List.generate(tips.length, (i) {
              final aktif = _indeksTips == i;
              final warna = (tips[i]['warna'] as List<Color>)[0];
              return GestureDetector(
                onTap: () {
                  setState(() => _indeksTips = i);
                  _tipsController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: aktif ? warna : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tips[i]['kategori'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: aktif ? Colors.white : Colors.grey[600],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Card carousel
        SizedBox(
          height: _indeksTips == 0 ? 110 : 220,
          child: PageView.builder(
            controller: _tipsController,
            itemCount: tips.length,
            onPageChanged: (i) => setState(() => _indeksTips = i),
            itemBuilder: (context, i) {
              final tip = tips[i];
              final gradienWarna = tip['warna'] as List<Color>;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradienWarna, begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: i == 0
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                            child: Icon(tip['ikon'] as IconData, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tip['kategori'] as String,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 3),
                                Text(tip['isi'] as String,
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      )
                    : i == 1
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.no_food_outlined, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Text('Makanan yang Perlu Dihindari',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ]),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: (tip['daftarMakanan'] as List).length,
                                itemBuilder: (_, j) {
                                  final item = (tip['daftarMakanan'] as List)[j] as Map<String, String>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 18, height: 18,
                                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.25), shape: BoxShape.circle),
                                          child: const Icon(Icons.close, color: Colors.white, size: 11),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: RichText(text: TextSpan(children: [
                                            TextSpan(text: item['nama']! + '  ',
                                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                            TextSpan(text: item['alasan'],
                                              style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 10.5)),
                                          ])),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [
                              Container(
                                width: 34, height: 34,
                                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(10)),
                                child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              const Text('Rekomendasi Olahraga',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                            ]),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: (tip['daftarOlahraga'] as List).length,
                                itemBuilder: (_, j) {
                                  final item = (tip['daftarOlahraga'] as List)[j] as Map<String, dynamic>;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(item['ikon'] as IconData, color: Colors.white.withValues(alpha: 0.9), size: 16),
                                        const SizedBox(width: 8),
                                        Text(item['nama'] as String,
                                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(item['durasi'] as String,
                                            style: const TextStyle(color: Colors.white, fontSize: 10)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        ),
        
        const SizedBox(height: 8),
        // Dot indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(tips.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: _indeksTips == i ? 20 : 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: _indeksTips == i
                ? (tips[i]['warna'] as List<Color>)[0]
                : Colors.grey[300],
              borderRadius: BorderRadius.circular(3),
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildNavBawah() {
    final daftarMenu = [
      {'ikon': Icons.home_rounded, 'label': 'Beranda'},
      {'ikon': Icons.bar_chart_rounded, 'label': 'Laporan'},
      {'ikon': null, 'label': 'Tambah'},
      {'ikon': Icons.history_rounded, 'label': 'Riwayat'},
      {'ikon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(daftarMenu.length, (i) {
          if (i == 2) {
            return GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FoodPhotoInputPage())),
              child: Container(
                width: 52, height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2979FF), shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Color(0x442979FF), blurRadius: 12, offset: Offset(0, 4))],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          }

          final aktif = _indeksAktif == i;
          final halamanTujuan = [null, const BloodSugarAnalysisPage(), null, const MealHistoryPage(), const HealthProfilePage()];

          return GestureDetector(
            onTap: () {
              setState(() => _indeksAktif = i);
              if (halamanTujuan[i] != null) Navigator.push(context, MaterialPageRoute(builder: (_) => halamanTujuan[i]!));
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(daftarMenu[i]['ikon'] as IconData, color: aktif ? const Color(0xFF2979FF) : Colors.grey[400], size: 24),
                const SizedBox(height: 3),
                Text(daftarMenu[i]['label'] as String,
                  style: TextStyle(fontSize: 10, color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  // ignore: unused_element
   Widget _buildEdukasi() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edukasi Kesehatan',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),

        ...daftarArtikel.map((artikel) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailArtikelPage(
                  artikel: artikel,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GAMBAR
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: Image.network(
                      artikel.gambar,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          artikel.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF2979FF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          artikel.isi,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    ),
  );
}
}

enum _KondisiGula { rendah, normal, tinggi, sangatTinggi }