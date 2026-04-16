// ============================================================
// FILE: admin_beranda_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Tab 1 - Beranda / Dashboard Admin
// FUNGSI: Menampilkan statistik total pasien, akun nonaktif,
//         pasien baru, artikel aktif, aktivitas terbaru,
//         dan kartu Editorial Insights.
// ============================================================

import 'package:flutter/material.dart';

class AdminBerandaPage extends StatelessWidget {
  const AdminBerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Header ──────────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 20),

              // ── 4 Kartu Statistik ────────────────────────────
              _buildGridStatistik(),
              const SizedBox(height: 20),

              // ── Aktivitas Terbaru ────────────────────────────
              _buildAktivitasTerbaru(),
              const SizedBox(height: 16),

              // ── Editorial Insights ───────────────────────────
              _buildEditorialInsights(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header dengan avatar AD dan ikon settings ────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // Avatar inisial AD
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'AD',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2340),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.settings_rounded,
              size: 20, color: Color(0xFF78909C)),
        ),
      ],
    );
  }

  // ── Grid 4 statistik ─────────────────────────────────────
  Widget _buildGridStatistik() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _kartuStat('128', 'TOTAL PASIEN', const Color(0xFF1A73E8)),
        _kartuStat('6', 'AKUN NONAKTIF', const Color(0xFFFF5252)),
        _kartuStat('14', 'PASIEN BARU', const Color(0xFF26A69A)),
        _kartuStat('9', 'ARTIKEL AKTIF', const Color(0xFFFFA726)),
      ],
    );
  }

  Widget _kartuStat(String nilai, String label, Color warna) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            nilai,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: warna,
              height: 1,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF90A4AE),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Aktivitas terbaru ─────────────────────────────────────
  Widget _buildAktivitasTerbaru() {
    final List<Map<String, dynamic>> aktivitas = [
      {
        'nama': 'Andi Wijaya',
        'aksi': 'catat gula darah: 120 mg/dL',
        'warna': const Color(0xFF1A73E8),
      },
      {
        'nama': 'Sari Putri',
        'aksi': 'melawatkan pencatatan harian',
        'warna': const Color(0xFFFFA726),
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AKTIVITAS TERBARU',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF90A4AE),
                  letterSpacing: 0.8,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'LIHAT SEMUA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A73E8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...aktivitas.map((a) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: a['warna'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${a['nama']}\n',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: Color(0xFF1A2340),
                          ),
                        ),
                        TextSpan(
                          text: a['aksi'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78909C),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  // ── Editorial Insights ────────────────────────────────────
  Widget _buildEditorialInsights() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Editorial Insights',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kelola data klinis dan artikel edukasi pasien dengan efisiensi tinggi melalui dashboard editorial terpadu.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF1A73E8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: const Text(
                'CEK REAL',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}