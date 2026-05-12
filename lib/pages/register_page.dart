import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'dart:convert';
import 'login_page.dart';
import 'dashboard_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // ── Step: 0=Form Data, 1=Pilih Tipe Diabetes, 2=OTP ──────
  int _step = 0;

  // ── Controller data diri ──────────────────────────────────
  final _namaCtrl         = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passwordCtrl     = TextEditingController();
  final _konfirmasiCtrl   = TextEditingController();
  final _tinggiBadanCtrl  = TextEditingController();
  final _beratBadanCtrl   = TextEditingController();
  final _umurCtrl         = TextEditingController();

  // ── Controller OTP (6 digit) ──────────────────────────────
  final List<TextEditingController> _otpCtrls =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus =
      List.generate(6, (_) => FocusNode());

  // ── State pilihan ─────────────────────────────────────────
  bool _sembunyikanPassword   = true;
  bool _sembunyikanKonfirmasi = true;
  bool _sedangMemuat          = false;
  bool _otpTerkirim           = false;
  String _jenisKelamin        = 'Laki-laki';
  String _tipeDiabetes        = 'Tipe 2';
  DateTime? _tanggalLahir;

  // OTP simulasi (di produksi pakai backend)
  String _otpBenar = '123456';

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _konfirmasiCtrl.dispose();
    _tinggiBadanCtrl.dispose();
    _beratBadanCtrl.dispose();
    _umurCtrl.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final f in _otpFocus) f.dispose();
    super.dispose();
  }

  // ── Validasi step 0 dan lanjut ke step 1 ─────────────────
  void _lanjutKeTipeDiabetes() {
    final nama     = _namaCtrl.text.trim();
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final konfirm  = _konfirmasiCtrl.text.trim();
    final tinggi   = _tinggiBadanCtrl.text.trim();
    final berat    = _beratBadanCtrl.text.trim();
    final umur     = _umurCtrl.text.trim();

    if ([nama, email, password, konfirm, tinggi, berat, umur]
        .any((v) => v.isEmpty)) {
      _snackbar('Semua kolom wajib diisi', Colors.red);
      return;
    }
    if (!email.contains('@')) {
      _snackbar('Format email tidak valid', Colors.red);
      return;
    }
    if (password.length < 8) {
      _snackbar('Password minimal 8 karakter', Colors.red);
      return;
    }
    if (password != konfirm) {
      _snackbar('Konfirmasi kata sandi tidak cocok', Colors.red);
      return;
    }
    if (_tanggalLahir == null) {
      _snackbar('Pilih tanggal lahir terlebih dahulu', Colors.red);
      return;
    }
    setState(() => _step = 1);
  }

  // ── Kirim OTP ke email ────────────────────────────────────
  Future<void> _kirimOTP() async {
    setState(() => _sedangMemuat = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    setState(() {
      _sedangMemuat = false;
      _otpTerkirim  = true;
      _step = 2;
    });
    _snackbar(
      '✉️ Kode OTP dikirim ke ${_emailCtrl.text.trim()}',
      const Color(0xFF26A69A),
    );
  }

  // ── Verifikasi OTP ────────────────────────────────────────
  Future<void> _verifikasiOTP() async {
    final inputOTP = _otpCtrls.map((c) => c.text).join();
    if (inputOTP.length < 6) {
      _snackbar('Masukkan 6 digit kode OTP', Colors.red);
      return;
    }
    if (inputOTP != _otpBenar) {
      _snackbar('Kode OTP salah. Coba lagi.', Colors.red);
      return;
    }
    setState(() => _sedangMemuat = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _sedangMemuat = false);

    if (!mounted) return;
    _snackbar('✅ Registrasi berhasil! Selamat datang.', const Color(0xFF26A69A));
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardPage()),
    );
  }

  // ── Kirim ulang OTP ───────────────────────────────────────
  Future<void> _kirimUlangOTP() async {
    for (final c in _otpCtrls) c.clear();
    setState(() => _sedangMemuat = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _sedangMemuat = false);
    _snackbar('Kode OTP baru dikirim ulang', const Color(0xFF1A73E8));
  }

  // ── Pilih tanggal lahir ───────────────────────────────────
  Future<void> _pilihTanggalLahir() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF1A73E8),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _tanggalLahir = picked;
        _umurCtrl.text =
            (DateTime.now().year - picked.year).toString();
      });
    }
  }

  void _snackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: warna,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  String get _tglLahirText {
    if (_tanggalLahir == null) return 'Pilih Tanggal Lahir';
    return '${_tanggalLahir!.day.toString().padLeft(2, '0')} '
        '${_bulanIndo(_tanggalLahir!.month)} '
        '${_tanggalLahir!.year}';
  }

  String _bulanIndo(int m) {
    const b = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return b[m];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header progress ──────────────────────────────
            _buildHeader(),

            // ── Konten step ──────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                child: _step == 0
                    ? _buildFormDataDiri()
                    : _step == 1
                        ? _buildPilihTipeDiabetes()
                        : _buildFormOTP(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header dengan progress bar 3 step ────────────────────
  Widget _buildHeader() {
    final labels = ['Data Diri', 'Tipe Diabetes', 'Verifikasi'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              if (_step > 0)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: Color(0xFF1A2340)),
                  onPressed: () => setState(() => _step--),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              else
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: Color(0xFF1A2340)),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 10),
              const Text(
                'Buat Akun',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2340),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper visual
          Row(
            children: List.generate(3, (i) {
              final bool done   = i < _step;
              final bool active = i == _step;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            height: 4,
                            decoration: BoxDecoration(
                              color: done || active
                                  ? const Color(0xFF1A73E8)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: active
                                  ? const Color(0xFF1A73E8)
                                  : done
                                      ? const Color(0xFF26A69A)
                                      : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < 2) const SizedBox(width: 6),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP 0 — Form Data Diri
  // ══════════════════════════════════════════════════════════
  Widget _buildFormDataDiri() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Lengkapi Data Diri',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2340),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Informasi ini digunakan untuk pemantauan kesehatan Anda',
          style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 20),

        // ── Kartu Data Akun ────────────────────────────────
        _buildKartuSection('Data Akun', Icons.person_rounded, [
          _fieldInput(_namaCtrl, 'Nama Lengkap', Icons.person_rounded),
          _fieldInput(_emailCtrl, 'Email', Icons.email_rounded,
              keyboard: TextInputType.emailAddress),
          _fieldPassword(_passwordCtrl, 'Kata Sandi',
              _sembunyikanPassword,
              () => setState(() => _sembunyikanPassword = !_sembunyikanPassword)),
          _fieldPassword(_konfirmasiCtrl, 'Konfirmasi Kata Sandi',
              _sembunyikanKonfirmasi,
              () => setState(() => _sembunyikanKonfirmasi = !_sembunyikanKonfirmasi)),
        ]),

        const SizedBox(height: 14),

        // ── Kartu Data Fisik ───────────────────────────────
        _buildKartuSection('Data Fisik', Icons.straighten_rounded, [

          // Tanggal lahir
          GestureDetector(
            onTap: _pilihTanggalLahir,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.cake_rounded,
                      color: Color(0xFF1A73E8), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _tglLahirText,
                      style: TextStyle(
                        fontSize: 14,
                        color: _tanggalLahir == null
                            ? const Color(0xFFB0BEC5)
                            : const Color(0xFF1A2340),
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_today_rounded,
                      size: 16, color: Color(0xFF78909C)),
                ],
              ),
            ),
          ),

          // Umur (readonly, auto dari tanggal lahir)
          _fieldInput(_umurCtrl, 'Umur (tahun)', Icons.numbers_rounded,
              keyboard: TextInputType.number, readOnly: true),

          // Tinggi & Berat berdampingan
          Row(
            children: [
              Expanded(
                child: _fieldInput(
                  _tinggiBadanCtrl,
                  'Tinggi (cm)',
                  Icons.height_rounded,
                  keyboard: TextInputType.number,
                  suffix: 'cm',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _fieldInput(
                  _beratBadanCtrl,
                  'Berat (kg)',
                  Icons.monitor_weight_rounded,
                  keyboard: TextInputType.number,
                  suffix: 'kg',
                ),
              ),
            ],
          ),

          // Jenis Kelamin
          const Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF78909C),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['Laki-laki', 'Perempuan'].map((jk) {
              final bool aktif = _jenisKelamin == jk;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _jenisKelamin = jk),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(
                        right: jk == 'Laki-laki' ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: aktif
                          ? const Color(0xFF1A73E8)
                          : const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: aktif
                            ? const Color(0xFF1A73E8)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          jk == 'Laki-laki'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 18,
                          color: aktif
                              ? Colors.white
                              : const Color(0xFF5B7DB1),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          jk,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: aktif
                                ? Colors.white
                                : const Color(0xFF5B7DB1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),

        const SizedBox(height: 24),

        // Tombol lanjut
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _lanjutKeTipeDiabetes,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Lanjutkan →',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        const SizedBox(height: 16),

        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Sudah punya akun? ',
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600)),
              GestureDetector(
                onTap: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const LoginPage()),
                ),
                child: const Text(
                  'Masuk',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A73E8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP 1 — Pilih Tipe Diabetes + Penjelasan
  // ══════════════════════════════════════════════════════════
  Widget _buildPilihTipeDiabetes() {
    final List<Map<String, dynamic>> tipeList = [
      {
        'tipe': 'Tipe 1',
        'ikon': Icons.bolt_rounded,
        'warna': const Color(0xFF1A73E8),
        'singkat': 'Sistem imun menyerang sel pankreas penghasil insulin.',
        'deskripsi':
            'Diabetes Tipe 1 adalah penyakit autoimun di mana sistem kekebalan tubuh menyerang dan menghancurkan sel beta pankreas yang menghasilkan insulin. Penderita harus bergantung pada injeksi insulin seumur hidup. Umumnya muncul pada anak-anak dan remaja.',
        'ciri': ['Onset cepat', 'Perlu insulin setiap hari', 'Biasa sejak muda'],
      },
      {
        'tipe': 'Tipe 2',
        'ikon': Icons.water_drop_rounded,
        'warna': const Color(0xFF26A69A),
        'singkat': 'Tubuh tidak menggunakan insulin dengan efektif.',
        'deskripsi':
            'Diabetes Tipe 2 terjadi ketika tubuh tidak dapat menggunakan insulin secara efektif (resistensi insulin) atau pankreas tidak memproduksi cukup insulin. Jenis ini paling umum dan sering berhubungan dengan gaya hidup tidak sehat, obesitas, dan usia.',
        'ciri': ['Paling umum (90%)', 'Bisa dikontrol gaya hidup', 'Sering pada dewasa'],
      },
      {
        'tipe': 'Gestasional',
        'ikon': Icons.pregnant_woman_rounded,
        'warna': const Color(0xFFAB47BC),
        'singkat': 'Terjadi saat kehamilan, biasanya hilang setelah melahirkan.',
        'deskripsi':
            'Diabetes gestasional berkembang selama kehamilan pada wanita yang sebelumnya tidak menderita diabetes. Kondisi ini terjadi karena perubahan hormon yang membuat sel tubuh lebih sulit merespons insulin. Biasanya sembuh setelah melahirkan, namun meningkatkan risiko Tipe 2 di masa depan.',
        'ciri': ['Khusus ibu hamil', 'Biasanya sementara', 'Butuh pemantauan ketat'],
      },
      {
        'tipe': 'Pra-Diabetes',
        'ikon': Icons.warning_amber_rounded,
        'warna': const Color(0xFFFFA726),
        'singkat': 'Gula darah tinggi namun belum mencapai batas diabetes.',
        'deskripsi':
            'Pra-diabetes adalah kondisi di mana kadar gula darah lebih tinggi dari normal, tetapi belum cukup tinggi untuk didiagnosis sebagai diabetes Tipe 2. Ini adalah sinyal peringatan. Dengan perubahan gaya hidup yang tepat, kondisi ini dapat dicegah agar tidak berkembang menjadi diabetes.',
        'ciri': ['Gula darah 100–125 mg/dL', 'Bisa dicegah', 'Perlu gaya hidup sehat'],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        const Text(
          'Tipe Diabetes Anda',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2340),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Pilih kondisi yang sesuai untuk panduan yang lebih tepat',
          style: TextStyle(fontSize: 13, color: Color(0xFF78909C)),
        ),
        const SizedBox(height: 20),

        // Kartu pilihan tipe
        ...tipeList.map((t) => _kartuTipeDiabetes(t)),

        const SizedBox(height: 16),

        // Tombol lanjut kirim OTP
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _sedangMemuat ? null : _kirimOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _sedangMemuat
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Kirim Kode OTP ke Email →',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _kartuTipeDiabetes(Map<String, dynamic> t) {
    final bool selected = _tipeDiabetes == t['tipe'];
    final Color warna   = t['warna'] as Color;

    return GestureDetector(
      onTap: () => setState(() => _tipeDiabetes = t['tipe']),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? warna.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? warna : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: warna.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: warna.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(t['ikon'] as IconData,
                      color: warna, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Diabetes ${t['tipe']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: selected
                              ? warna
                              : const Color(0xFF1A2340),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t['singkat'],
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF78909C)),
                      ),
                    ],
                  ),
                ),
                // Radio indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color:
                            selected ? warna : Colors.grey.shade300,
                        width: 2),
                    color: selected ? warna : Colors.transparent,
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 14)
                      : null,
                ),
              ],
            ),

            // Deskripsi + ciri (expand saat dipilih)
            if (selected) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFEEF2F8)),
              const SizedBox(height: 10),
              Text(
                t['deskripsi'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF455A64),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (t['ciri'] as List<String>).map((c) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: warna.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '✓ $c',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: warna,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // STEP 2 — Verifikasi OTP
  // ══════════════════════════════════════════════════════════
  Widget _buildFormOTP() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),

        // Ikon email
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 48, color: Color(0xFF1A73E8)),
        ),
        const SizedBox(height: 20),

        const Text(
          'Cek Email Anda',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2340),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: const TextStyle(
                fontSize: 13, color: Color(0xFF78909C), height: 1.5),
            children: [
              const TextSpan(text: 'Kode OTP 6 digit telah dikirim ke\n'),
              TextSpan(
                text: _emailCtrl.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A73E8),
                ),
              ),
            ],
          ),
        ),

        // Info simulasi
        Container(
          margin: const EdgeInsets.only(top: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFFE082)),
          ),
          child: const Text(
            '🔑 Demo: gunakan kode  123456',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFFE65100),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Input 6 kotak OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Container(
              width: 46,
              height: 54,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _otpCtrls[i].text.isNotEmpty
                      ? const Color(0xFF1A73E8)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                  )
                ],
              ),
              child: TextField(
                controller: _otpCtrls[i],
                focusNode: _otpFocus[i],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A73E8),
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                onChanged: (v) {
                  setState(() {});
                  if (v.isNotEmpty && i < 5) {
                    _otpFocus[i + 1].requestFocus();
                  } else if (v.isEmpty && i > 0) {
                    _otpFocus[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 28),

        // Tombol verifikasi
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _sedangMemuat ? null : _verifikasiOTP,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: _sedangMemuat
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5),
                  )
                : const Text(
                    'Verifikasi & Daftar',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Kirim ulang OTP
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Tidak menerima kode? ',
                style: TextStyle(
                    fontSize: 13, color: Color(0xFF78909C))),
            GestureDetector(
              onTap: _sedangMemuat ? null : _kirimUlangOTP,
              child: const Text(
                'Kirim Ulang',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // HELPER WIDGET
  // ══════════════════════════════════════════════════════════

  Widget _buildKartuSection(
      String judul, IconData ikon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ikon, color: const Color(0xFF1A73E8), size: 16),
              const SizedBox(width: 6),
              Text(
                judul,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A73E8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _fieldInput(
    TextEditingController ctrl,
    String label,
    IconData ikon, {
    TextInputType keyboard = TextInputType.text,
    bool readOnly = false,
    String? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        readOnly: readOnly,
        inputFormatters: keyboard == TextInputType.number
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          prefixIcon: Icon(ikon,
              color: const Color(0xFF1A73E8), size: 20),
          filled: true,
          fillColor: readOnly
              ? const Color(0xFFF5F7FA)
              : const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF1A73E8), width: 1.5)),
        ),
      ),
    );
  }

  Widget _fieldPassword(
    TextEditingController ctrl,
    String label,
    bool sembunyikan,
    VoidCallback onToggle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        obscureText: sembunyikan,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline_rounded,
              color: Color(0xFF1A73E8), size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              sembunyikan ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: const Color(0xFFF0F4FF),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: Color(0xFF1A73E8), width: 1.5)),
        ),
      ),
    ); 
  }
}