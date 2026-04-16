// ============================================================
// FILE: admin_pasien_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Tab 2 - Kelola Pasien
// FUNGSI: Admin dapat mencari pasien, melihat ringkasan
//         populasi, daftar pasien dengan badge tipe diabetes,
//         tombol Nonaktifkan / Aktifkan akun pasien.
// ============================================================

import 'package:flutter/material.dart';

// Model data pasien
class DataPasienAdmin {
  final String inisial;
  final String nama;
  final String email;
  final String tipe;
  bool aktif;

  DataPasienAdmin({
    required this.inisial,
    required this.nama,
    required this.email,
    required this.tipe,
    required this.aktif,
  });
}

class AdminPasienPage extends StatefulWidget {
  const AdminPasienPage({super.key});

  @override
  State<AdminPasienPage> createState() => _AdminPasienPageState();
}

class _AdminPasienPageState extends State<AdminPasienPage> {
  final _cariCtrl = TextEditingController();

  final List<DataPasienAdmin> _semuaPasien = [
    DataPasienAdmin(inisial: 'AW', nama: 'Andi Wijaya',  email: 'andi@email.com',    tipe: 'Tipe 2', aktif: true),
    DataPasienAdmin(inisial: 'SP', nama: 'Sari Putri',   email: 'sari.p@mail.com',   tipe: 'Tipe 1', aktif: true),
    DataPasienAdmin(inisial: 'BS', nama: 'Budi Santoso', email: 'budi@provider.net', tipe: 'Tipe 2', aktif: false),
    DataPasienAdmin(inisial: 'DL', nama: 'Dewi Lestari', email: 'dewi@mail.com',     tipe: 'Tipe 2', aktif: true),
    DataPasienAdmin(inisial: 'RM', nama: 'Rudi Maulana', email: 'rudi@gmail.com',    tipe: 'Tipe 1', aktif: false),
  ];

  List<DataPasienAdmin> get _filtered {
    if (_cariCtrl.text.isEmpty) return _semuaPasien;
    return _semuaPasien
        .where((p) => p.nama.toLowerCase().contains(_cariCtrl.text.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final aktifCount = _semuaPasien.where((p) => p.aktif).length;
    final persen = (_semuaPasien.isEmpty)
        ? 0.0
        : aktifCount / _semuaPasien.length * 100;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [

            // ── AppBar manual ──────────────────────────────
            _buildAppBar(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Banner biru "Kelola Pasien" ─────────
                    _buildBannerKelola(),
                    const SizedBox(height: 16),

                    // ── Search bar ──────────────────────────
                    _buildSearchBar(),
                    const SizedBox(height: 12),

                    // ── Tombol Tambah Pasien ────────────────
                    _buildTombolTambah(context),
                    const SizedBox(height: 16),

                    // ── Ringkasan Populasi ──────────────────
                    _buildRingkasanPopulasi(aktifCount, persen),
                    const SizedBox(height: 16),

                    // ── Label daftar ────────────────────────
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'DAFTAR PASIEN TERBARU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF90A4AE),
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Daftar pasien ───────────────────────
                    ..._filtered.map((p) => _buildKartuPasien(p)),

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

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Admin Log Medis',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2340),
            ),
          ),
          const Icon(Icons.notifications_none_rounded,
              color: Color(0xFF78909C), size: 24),
        ],
      ),
    );
  }

  Widget _buildBannerKelola() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Kelola Pasien',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Monitor dan kelola profil kesehatan seluruh pasien Anda dalam satu dashboard editorial yang presisi.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _cariCtrl,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari nama pasien...',
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Color(0xFFB0BEC5), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTombolTambah(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () => _dialogTambahPasien(context),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text(
          '+ Tambah Pasien',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A73E8),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildRingkasanPopulasi(int aktif, double persen) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RINGKASAN POPULASI',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF90A4AE),
                  letterSpacing: 0.8,
                ),
              ),
              const Icon(Icons.open_in_new_rounded,
                  size: 16, color: Color(0xFF90A4AE)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_semuaPasien.length.toString().padLeft(4, ' ')}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A2340),
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    'TOTAL PASIEN',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${persen.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A73E8),
                      letterSpacing: -1,
                    ),
                  ),
                  const Text(
                    'TINGKAT AKTIVITAS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF90A4AE),
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKartuPasien(DataPasienAdmin p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar inisial
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                p.inisial,
                style: const TextStyle(
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info pasien
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${p.email} • ${p.tipe}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Badge status aktif/nonaktif
                    _badgeStatus(p.aktif),
                    const SizedBox(width: 8),
                    // Tombol toggle
                    GestureDetector(
                      onTap: () => setState(() => p.aktif = !p.aktif),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.aktif
                              ? const Color(0xFFFFEBEE)
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          p.aktif ? 'Nonaktifkan' : 'Aktifkan',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: p.aktif
                                ? const Color(0xFFE53935)
                                : const Color(0xFF1A73E8),
                          ),
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

  Widget _badgeStatus(bool aktif) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: aktif
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        aktif ? 'AKTIF' : 'NONAKTIF',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: aktif ? const Color(0xFF43A047) : Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Dialog tambah pasien baru
  void _dialogTambahPasien(BuildContext context) {
    final namaCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    String tipe = 'Tipe 2';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tambah Pasien Baru',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2340)),
              ),
              const SizedBox(height: 16),
              _inputField(namaCtrl, 'Nama Lengkap', Icons.person_rounded),
              const SizedBox(height: 12),
              _inputField(emailCtrl, 'Email', Icons.email_rounded,
                  keyboard: TextInputType.emailAddress),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: tipe,
                decoration: InputDecoration(
                  labelText: 'Tipe Diabetes',
                  prefixIcon: const Icon(Icons.medical_information_rounded,
                      color: Color(0xFF1A73E8), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF0F4FF),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: ['Tipe 1', 'Tipe 2', 'Pra-Diabetes']
                    .map((t) =>
                        DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setModalState(() => tipe = v!),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    if (namaCtrl.text.trim().isNotEmpty) {
                      final inisial = namaCtrl.text
                          .trim()
                          .split(' ')
                          .take(2)
                          .map((w) => w[0].toUpperCase())
                          .join();
                      setState(() {
                        _semuaPasien.add(DataPasienAdmin(
                          inisial: inisial,
                          nama: namaCtrl.text.trim(),
                          email: emailCtrl.text.trim(),
                          tipe: tipe,
                          aktif: true,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan',
                      style: TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1A73E8), size: 20),
        filled: true,
        fillColor: const Color(0xFFF0F4FF),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF1A73E8), width: 1.5)),
      ),
    );
  }
}