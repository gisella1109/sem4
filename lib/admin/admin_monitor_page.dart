// ============================================================
// FILE: admin_monitor_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Tab 4 - Monitoring Pasien
// FUNGSI: Admin memantau data gula darah pasien. Menampilkan
//         daftar pasien (filter Data Pasien), tabel data gula
//         darah per pasien (waktu, kadar, status, aksi),
//         tab Mingguan/Harian, dan log aktivitas pasien.
// ============================================================

import 'package:flutter/material.dart';

// ── Model data gula darah untuk monitoring ────────────────────
class DataGulaMonitor {
  final String waktu;
  final int kadar;
  final String status; // 'NORMAL' atau 'TINGGI'

  const DataGulaMonitor({
    required this.waktu,
    required this.kadar,
    required this.status,
  });
}

// ── Model log aktivitas ───────────────────────────────────────
class LogAktivitas {
  final String judul;
  final String deskripsi;

  const LogAktivitas({required this.judul, required this.deskripsi});
}

class AdminMonitorPage extends StatefulWidget {
  const AdminMonitorPage({super.key});

  @override
  State<AdminMonitorPage> createState() => _AdminMonitorPageState();
}

class _AdminMonitorPageState extends State<AdminMonitorPage> {
  // Pasien yang sedang dipilih untuk dimonitor
  int _selectedPasien = 2; // default index Dewi Lestari (highlighted di desain)
  String _tabGula = 'Harian'; // 'Mingguan' atau 'Harian'

  // Data pasien untuk monitoring
  final List<Map<String, dynamic>> _pasien = [
    {'nama': 'Andi Wijaya',  'usia': 45, 'jk': 'Laki-laki',   'tipe': 'TIPE 2'},
    {'nama': 'Sari Putri',   'usia': 38, 'jk': 'Perempuan',   'tipe': 'TIPE 1'},
    {'nama': 'Dewi Lestari', 'usia': 52, 'jk': 'Perempuan',   'tipe': 'TIPE 2'},
    {'nama': 'Budi Santoso', 'usia': 60, 'jk': 'Laki-laki',   'tipe': 'TIPE 2'},
  ];

  // Data gula darah harian pasien terpilih
  final List<DataGulaMonitor> _dataGula = [
    DataGulaMonitor(waktu: '08:00 WIB', kadar: 120, status: 'NORMAL'),
    DataGulaMonitor(waktu: '12:30 WIB', kadar: 215, status: 'TINGGI'),
    DataGulaMonitor(waktu: '18:15 WIB', kadar: 108, status: 'NORMAL'),
    DataGulaMonitor(waktu: '22:00 WIB', kadar: 189, status: 'TINGGI'),
  ];

  // Log aktivitas pasien
  final List<LogAktivitas> _logAktivitas = [
    LogAktivitas(
      judul: 'Pencatatan Gula Darah Pagi',
      deskripsi:
          'Dewi Lestari mencatatkan kadar gula darah 120 mg/dL (Status: Normal) setelah sarapan pagi',
    ),
    LogAktivitas(
      judul: 'Log Makan Siang',
      deskripsi:
          'Mencatat konsumsi nasi putih + ayam goreng, estimasi 620 kkal',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // ── AppBar ───────────────────────────────────────
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    // ── Profil admin ─────────────────────────
                    _buildProfilAdmin(),

                    // ── Konten utama ─────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // ── Daftar pasien ───────────────────
                          _buildSeksi('DATA PASIEN', null),
                          const SizedBox(height: 10),
                          _buildDaftarPasien(),
                          const SizedBox(height: 20),

                          // ── Tabel gula darah ────────────────
                          _buildSeksi('DATA GULA DARAH', _buildTabGula()),
                          const SizedBox(height: 10),
                          _buildTabelGula(),
                          const SizedBox(height: 20),

                          // ── Log aktivitas ────────────────────
                          _buildSeksi('LOG AKTIVITAS', null),
                          const SizedBox(height: 10),
                          _buildLogAktivitas(),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.show_chart_rounded,
                      size: 18, color: Color(0xFF1A73E8)),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Wefiname',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2340),
                ),
              ),
            ],
          ),
          // Foto profil admin
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profil admin strip ────────────────────────────────────
  Widget _buildProfilAdmin() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          const SizedBox(width: 44), // align dengan ikon di AppBar
          const SizedBox(width: 10),
          const Text(
            '',
            style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
          ),
        ],
      ),
    );
  }

  // ── Judul seksi ───────────────────────────────────────────
  Widget _buildSeksi(String judul, Widget? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          judul,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF90A4AE),
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── Tab Mingguan/Harian ───────────────────────────────────
  Widget _buildTabGula() {
    return Row(
      children: ['Mingguan', 'Harian'].map((t) {
        final aktif = _tabGula == t;
        return GestureDetector(
          onTap: () => setState(() => _tabGula = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: aktif
                  ? const Color(0xFF1A73E8)
                  : const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: aktif ? Colors.white : const Color(0xFF90A4AE),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Daftar pasien untuk dipilih ───────────────────────────
  Widget _buildDaftarPasien() {
    return Column(
      children: List.generate(_pasien.length, (i) {
        final p = _pasien[i];
        final selected = _selectedPasien == i;
        return GestureDetector(
          onTap: () => setState(() => _selectedPasien = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFE3F2FD)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? const Color(0xFF1A73E8)
                    : Colors.grey.shade100,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p['nama'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF1A2340),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p['usia']} th • ${p['jk']}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF90A4AE)),
                      ),
                    ],
                  ),
                ),
                // Badge tipe
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    p['tipe'],
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── Tabel data gula darah ─────────────────────────────────
  Widget _buildTabelGula() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          // Header tabel
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'WAKTU',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'KADAR\n(MG/DL)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'AKSI',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Baris data
          ..._dataGula.map((d) => _barisTabel(d)),
        ],
      ),
    );
  }

  Widget _barisTabel(DataGulaMonitor d) {
    final bool tinggi = d.status == 'TINGGI';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          // Waktu
          Expanded(
            flex: 3,
            child: Text(
              d.waktu,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A2340),
              ),
            ),
          ),

          // Kadar
          Expanded(
            flex: 3,
            child: Text(
              '${d.kadar}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: tinggi
                    ? const Color(0xFFE53935)
                    : const Color(0xFF1A2340),
              ),
            ),
          ),

          // Status badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: tinggi
                    ? const Color(0xFFFFEBEE)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                d.status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: tinggi
                      ? const Color(0xFFE53935)
                      : const Color(0xFF43A047),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),

          // Aksi
          Expanded(
            flex: 1,
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: Color(0xFFB0BEC5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Log aktivitas pasien ──────────────────────────────────
  Widget _buildLogAktivitas() {
    return Column(
      children: _logAktivitas.map((log) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A73E8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.judul,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A73E8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.deskripsi,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF78909C),
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}