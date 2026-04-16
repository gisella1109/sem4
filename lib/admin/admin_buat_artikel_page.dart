// ============================================================
// FILE: admin_buat_artikel_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Halaman Buat / Edit Artikel
// FUNGSI: Form editor artikel: judul, isi artikel (toolbar
//         format bold/italic/list), pilih kategori dropdown,
//         upload gambar sampul, tombol Terbitkan & Simpan Draf.
// ============================================================

import 'package:flutter/material.dart';
import 'admin_artikel_page.dart';

class AdminBuatArtikelPage extends StatefulWidget {
  final DataArtikel? artikelEdit; // null = buat baru
  final void Function(DataArtikel) onSimpan;

  const AdminBuatArtikelPage({
    super.key,
    this.artikelEdit,
    required this.onSimpan,
  });

  @override
  State<AdminBuatArtikelPage> createState() =>
      _AdminBuatArtikelPageState();
}

class _AdminBuatArtikelPageState extends State<AdminBuatArtikelPage> {
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  String _kategori = 'KESEHATAN JANTUNG';
  bool _adaGambar = false;
  bool _isSaving = false;

  final List<String> _kategoriList = [
    'KESEHATAN JANTUNG',
    'NUTRISI',
    'GAYA HIDUP',
    'MEDIS',
    'MENTAL HEALTH',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.artikelEdit != null) {
      _judulCtrl.text = widget.artikelEdit!.judul;
      _isiCtrl.text = widget.artikelEdit!.isiSingkat;
      _kategori = widget.artikelEdit!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _terbitkan() async {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Judul artikel tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isSaving = false);

    final artikel = DataArtikel(
      judul: _judulCtrl.text.trim(),
      kategori: _kategori,
      tanggal: 'Diterbitkan hari ini',
      views: widget.artikelEdit?.views ?? 0,
      komentar: widget.artikelEdit?.komentar ?? 0,
      diterbitkan: true,
      isiSingkat: _isiCtrl.text.trim().isEmpty
          ? 'Konten artikel baru...'
          : _isiCtrl.text.trim(),
    );
    widget.onSimpan(artikel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Artikel berhasil diterbitkan!'),
          backgroundColor: Color(0xFF26A69A),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _simpanDraf() async {
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _isSaving = false);

    final artikel = DataArtikel(
      judul: _judulCtrl.text.trim().isEmpty
          ? 'Artikel tanpa judul'
          : _judulCtrl.text.trim(),
      kategori: _kategori,
      tanggal: 'Draf — belum diterbitkan',
      views: 0,
      komentar: 0,
      diterbitkan: false,
      isiSingkat: _isiCtrl.text.trim(),
    );
    widget.onSimpan(artikel);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📝 Tersimpan sebagai draf'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEdit = widget.artikelEdit != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Color(0xFF1A2340)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Artikel' : 'Buat Artikel Baru',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A2340),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : _terbitkan,
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF1A73E8),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text(
                'Simpan',
                style:
                    TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Judul artikel ────────────────────────────────
            const Text(
              'Judul Artikel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78909C),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _judulCtrl,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A2340),
                ),
                decoration: const InputDecoration(
                  hintText: 'Masukkan judul yang menarik\ndan informatif...',
                  hintStyle:
                      TextStyle(color: Color(0xFFB0BEC5), fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Toolbar format teks ──────────────────────────
            const Text(
              'Isi Artikel',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF78909C),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // Toolbar ikon format
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200)),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _toolbarBtn('B',
                            bold: true, color: const Color(0xFF1A2340)),
                        _toolbarBtn('I',
                            italic: true, color: const Color(0xFF78909C)),
                        _toolbarIcon(Icons.format_underline_rounded),
                        _toolbarIcon(Icons.format_list_bulleted_rounded),
                        _toolbarIcon(Icons.format_list_numbered_rounded),
                        _toolbarIcon(Icons.format_quote_rounded),
                        _toolbarIcon(Icons.link_rounded),
                        _toolbarIcon(Icons.image_rounded),
                      ],
                    ),
                  ),
                  // Area tulis
                  TextField(
                    controller: _isiCtrl,
                    maxLines: 8,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF455A64),
                        height: 1.6),
                    decoration: const InputDecoration(
                      hintText:
                          'Mulai menulis konten medis Anda di sini...',
                      hintStyle: TextStyle(
                          color: Color(0xFFB0BEC5), fontSize: 13),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Kategori ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.label_rounded,
                          size: 16, color: Color(0xFF1A73E8)),
                      SizedBox(width: 8),
                      Text(
                        'Kategori',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _kategori,
                    decoration: InputDecoration(
                      hintText: 'Pilih Kategori',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    items: _kategoriList
                        .map((k) =>
                            DropdownMenuItem(value: k, child: Text(k)))
                        .toList(),
                    onChanged: (v) => setState(() => _kategori = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Gambar sampul ─────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.image_rounded,
                          size: 16, color: Color(0xFF1A73E8)),
                      SizedBox(width: 8),
                      Text(
                        'Gambar Sampul',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _adaGambar = !_adaGambar),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _adaGambar
                              ? const Color(0xFF1A73E8)
                              : Colors.grey.shade300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _adaGambar
                          ? Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1565C0),
                                    Color(0xFF42A5F5)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 40),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.cloud_upload_outlined,
                                    size: 32, color: Color(0xFFB0BEC5)),
                                SizedBox(height: 8),
                                Text(
                                  'Klik untuk unggah atau seret file',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF90A4AE)),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Tombol Terbitkan ──────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _terbitkan,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        '✦ Terbitkan Sekarang',
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
            const SizedBox(height: 10),

            // ── Tombol Simpan Draf ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _simpanDraf,
                icon: const Icon(Icons.save_outlined,
                    size: 18, color: Color(0xFF78909C)),
                label: const Text(
                  '✎ Simpan Sebagai Draf',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF78909C),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Info notice ───────────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFF1A73E8)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Artikel yang diterbitkan akan langsung dapat dilihat oleh pasien melalui tab Artikel di aplikasi. Pastikan informasi medis akurat.',
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF1565C0),
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _toolbarBtn(String label,
      {bool bold = false, bool italic = false, Color? color}) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: color ?? const Color(0xFF78909C),
          ),
        ),
      ),
    );
  }

  Widget _toolbarIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: const Color(0xFF78909C)),
      ),
    );
  }
}