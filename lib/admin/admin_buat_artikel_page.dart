import 'package:flutter/material.dart';
import '../models/artikel_model.dart';
import '../services/artikel_service.dart';

class AdminBuatArtikelPage extends StatefulWidget {
  final Artikel? artikelEdit;
  const AdminBuatArtikelPage({super.key, this.artikelEdit});

  @override
  State<AdminBuatArtikelPage> createState() => _AdminBuatArtikelPageState();
}

class _AdminBuatArtikelPageState extends State<AdminBuatArtikelPage> {
  final _judulCtrl = TextEditingController();
  final _isiCtrl   = TextEditingController();
  String _kategori  = 'Dasar';
  bool _isSaving    = false;

  final List<String> _kategoriList = ['Dasar', 'Nutrisi', 'Monitoring', 'Gaya Hidup'];

  bool get _isEdit => widget.artikelEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _judulCtrl.text = widget.artikelEdit!.judul;
      _isiCtrl.text   = widget.artikelEdit!.isi;
      _kategori       = widget.artikelEdit!.kategori;
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan(bool terbitkan) async {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Judul tidak boleh kosong'), backgroundColor: Colors.red));
      return;
    }
    setState(() => _isSaving = true);

    Map<String, dynamic> result;
    if (_isEdit) {
      result = await ArtikelService.updateArtikel(
        widget.artikelEdit!.id,
        judul:       _judulCtrl.text.trim(),
        isi:         _isiCtrl.text.trim(),
        kategori:    _kategori,
        isPublished: terbitkan,
      );
    } else {
      result = await ArtikelService.buatArtikel(
        judul:       _judulCtrl.text.trim(),
        isi:         _isiCtrl.text.trim(),
        kategori:    _kategori,
        isPublished: terbitkan,
      );
    }

    setState(() => _isSaving = false);

    if ((result['success'] as bool) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(terbitkan ? '✅ Artikel berhasil diterbitkan!' : '📝 Tersimpan sebagai draf'),
        backgroundColor: terbitkan ? const Color(0xFF26A69A) : Colors.blueGrey,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.pop(context);
    } else if (mounted) {
      final msg = result['data']?['message'] ?? 'Gagal menyimpan artikel';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A2340)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_isEdit ? 'Edit Artikel' : 'Buat Artikel Baru',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A2340))),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _isSaving ? null : () => _simpan(true),
              style: TextButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info penulis
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.admin_panel_settings_rounded, size: 18, color: Color(0xFF1A73E8)),
                SizedBox(width: 8),
                Text('Artikel ini akan dikirim ke semua pasien setelah diterbitkan.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1565C0))),
              ]),
            ),
            const SizedBox(height: 16),

            // Judul
            const Text('Judul Artikel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78909C))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                controller: _judulCtrl, maxLines: 2,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
                decoration: const InputDecoration(hintText: 'Masukkan judul yang menarik...', hintStyle: TextStyle(color: Color(0xFFB0BEC5), fontSize: 14), border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
              ),
            ),
            const SizedBox(height: 16),

            // Kategori
            const Text('Kategori', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78909C))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _kategori, isExpanded: true,
                  items: _kategoriList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                  onChanged: (v) => setState(() => _kategori = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Isi
            const Text('Isi Artikel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78909C))),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                controller: _isiCtrl, maxLines: 12,
                style: const TextStyle(fontSize: 13, color: Color(0xFF455A64), height: 1.6),
                decoration: const InputDecoration(hintText: 'Tulis konten edukasi untuk pasien...', hintStyle: TextStyle(color: Color(0xFFB0BEC5), fontSize: 13), border: InputBorder.none, contentPadding: EdgeInsets.all(14)),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol terbitkan
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : () => _simpan(true),
                icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send_rounded, size: 18),
                label: const Text('✦ Terbitkan ke Pasien', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A73E8), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol simpan draf
            SizedBox(
              width: double.infinity, height: 50,
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : () => _simpan(false),
                icon: const Icon(Icons.save_outlined, size: 18, color: Color(0xFF78909C)),
                label: const Text('✎ Simpan Sebagai Draf', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF78909C))),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey.shade300), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
