import 'package:flutter/material.dart';
import '../models/artikel_model.dart';
import '../services/artikel_service.dart';

class ArtikelEdukasiPage extends StatefulWidget {
  const ArtikelEdukasiPage({super.key});

  @override
  State<ArtikelEdukasiPage> createState() => _ArtikelEdukasiPageState();
}

class _ArtikelEdukasiPageState extends State<ArtikelEdukasiPage> {
  String _kategoriDipilih = 'Semua';
  bool _loading = true;
  List<Artikel> _semua = [];
  List<Artikel> _filtered = [];

  final List<String> _daftarKategori = ['Semua', 'Dasar', 'Nutrisi', 'Monitoring', 'Gaya Hidup'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await ArtikelService.fetchArtikel();
    setState(() {
      _semua    = list;
      _filtered = list;
      _loading  = false;
    });
  }

  void _filterKategori(String kategori) {
    setState(() {
      _kategoriDipilih = kategori;
      _filtered = kategori == 'Semua' ? _semua : _semua.where((a) => a.kategori == kategori).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5), elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)), onPressed: () => Navigator.pop(context)),
        title: const Text('Edukasi Diabetes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF1A1A2E)), onPressed: _load)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // Banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: GestureDetector(
                      onTap: () => _showTabelNutrisi(context),
                      child: Container(
                        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF2979FF), Color(0xFF448AFF)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.all(16),
                        child: const Row(children: [
                          Text('🍽', style: TextStyle(fontSize: 32)),
                          SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Panduan Nutrisi Diabetes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 4),
                            Text('Kalori • Karbo • Gula • Serat • Protein', style: TextStyle(fontSize: 12, color: Colors.white70)),
                          ])),
                          Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                        ]),
                      ),
                    ),
                  ),

                  // Filter
                  SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _daftarKategori.length,
                      itemBuilder: (context, i) {
                        final kat = _daftarKategori[i];
                        final dipilih = kat == _kategoriDipilih;
                        return GestureDetector(
                          onTap: () => _filterKategori(kat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!),
                            ),
                            child: Text(kat, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: dipilih ? Colors.white : Colors.grey[600])),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // List artikel
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Belum ada artikel', style: TextStyle(color: Colors.grey)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filtered.length,
                            itemBuilder: (context, i) => _buildKartu(context, _filtered[i]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildKartu(BuildContext context, Artikel a) {
    final warnaKat = _warnaKategori(a.kategori);
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailArtikelPage(artikel: a))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar / placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: a.gambar.isNotEmpty
                  ? Image.network(a.gambar, height: 140, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _placeholder(warnaKat))
                  : _placeholder(warnaKat),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: warnaKat.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                      child: Text(a.kategori, style: TextStyle(fontSize: 11, color: warnaKat, fontWeight: FontWeight.w600)),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(a.duraBaca, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ]),
                  const SizedBox(height: 8),
                  Text(a.judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),
                  Text(a.ringkasan, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(Icons.person_outline, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text(a.admin, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    const SizedBox(width: 10),
                    Icon(Icons.remove_red_eye_outlined, size: 12, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Text('${a.views}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(Color warna) {
    return Container(height: 140, color: warna.withOpacity(0.1), child: const Center(child: Text('📖', style: TextStyle(fontSize: 48))));
  }

  Color _warnaKategori(String kat) {
    switch (kat) {
      case 'Nutrisi':    return const Color(0xFF2979FF);
      case 'Monitoring': return Colors.green;
      case 'Gaya Hidup': return Colors.orange;
      case 'Dasar':      return Colors.purple;
      default:           return Colors.grey;
    }
  }

  void _showTabelNutrisi(BuildContext context) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const TabelNutrisiSheet());
  }
}

// ── Detail Artikel ────────────────────────────────────────────
class DetailArtikelPage extends StatelessWidget {
  final Artikel artikel;
  const DetailArtikelPage({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true,
          backgroundColor: const Color(0xFF2979FF),
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(fit: StackFit.expand, children: [
              artikel.gambar.isNotEmpty
                  ? Image.network(artikel.gambar, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2979FF)))
                  : Container(color: const Color(0xFF2979FF)),
              Container(color: Colors.black.withOpacity(0.35)),
            ]),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF2979FF).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(artikel.kategori, style: const TextStyle(fontSize: 12, color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(artikel.duraBaca, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ]),
                const SizedBox(height: 14),
                Text(artikel.judul, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.person_outline, size: 13, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text('oleh ${artikel.admin}', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                  const SizedBox(width: 12),
                  Text(artikel.createdAt, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ]),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildIsi(artikel.isi),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildIsi(String isi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: isi.split('\n').map((baris) {
        if (baris.isEmpty) return const SizedBox(height: 8);
        if (baris == baris.toUpperCase() && baris.trim().isNotEmpty && !baris.startsWith('•') && !baris.startsWith('✅') && !baris.startsWith('❌') && !baris.startsWith('⚠') && !baris.startsWith('─')) {
          return Padding(padding: const EdgeInsets.only(top: 16, bottom: 6), child: Text(baris, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2979FF), letterSpacing: 0.5)));
        }
        if (baris.startsWith('─')) return const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider());
        if (baris.startsWith('•') || baris.startsWith('✅') || baris.startsWith('❌') || baris.startsWith('⚠️')) {
          return Padding(padding: const EdgeInsets.only(bottom: 6, left: 4), child: Text(baris, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)));
        }
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(baris, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6)));
      }).toList(),
    );
  }
}

// ── Tabel Nutrisi Sheet ───────────────────────────────────────
class TabelNutrisiSheet extends StatelessWidget {
  const TabelNutrisiSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85, maxChildSize: 0.95, minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Panduan Nutrisi Diabetes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.symmetric(horizontal: 16), children: const [
            _ItemNutrisi(emoji: '🔥', nama: 'Kalori',      warna: Color(0xFFFF6B35), fungsi: 'Sumber energi tubuh',           efek: 'Kelebihan kalori → kenaikan berat badan & resistensi insulin', saran: '1500–2000 kkal/hari untuk dewasa'),
            _ItemNutrisi(emoji: '🌾', nama: 'Karbohidrat', warna: Color(0xFFFF8C00), fungsi: 'Sumber energi utama',           efek: 'Dicerna jadi glukosa, langsung menaikkan gula darah',          saran: 'Pilih karbohidrat kompleks: nasi merah, ubi, oatmeal'),
            _ItemNutrisi(emoji: '🍬', nama: 'Gula',        warna: Color(0xFFE53935), fungsi: 'Karbohidrat sederhana',         efek: 'Menaikkan gula darah sangat cepat',                           saran: 'Maks. 25g/hari. Hindari minuman manis'),
            _ItemNutrisi(emoji: '🥦', nama: 'Serat',       warna: Color(0xFF43A047), fungsi: 'Membantu pencernaan',           efek: 'Memperlambat penyerapan glukosa',                             saran: '25–30g/hari dari sayuran, buah, biji-bijian'),
            _ItemNutrisi(emoji: '🍗', nama: 'Protein',     warna: Color(0xFF2979FF), fungsi: 'Membangun & memperbaiki tubuh', efek: 'Tidak langsung pengaruhi gula darah',                         saran: 'Ikan, ayam tanpa kulit, tahu, tempe'),
            SizedBox(height: 24),
          ])),
        ]),
      ),
    );
  }
}

class _ItemNutrisi extends StatelessWidget {
  final String emoji, nama, fungsi, efek, saran;
  final Color warna;
  const _ItemNutrisi({required this.emoji, required this.nama, required this.warna, required this.fungsi, required this.efek, required this.saran});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: warna.withOpacity(0.05), borderRadius: BorderRadius.circular(14), border: Border.all(color: warna.withOpacity(0.2))),
      child: ExpansionTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: warna.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20)))),
        title: Text(nama, style: TextStyle(fontWeight: FontWeight.bold, color: warna, fontSize: 15)),
        subtitle: Text(fungsi, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        iconColor: warna, collapsedIconColor: Colors.grey[400],
        children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⚡ Efek:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.red[700])),
          const SizedBox(height: 4),
          Text(efek, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
          const SizedBox(height: 8),
          Text('✅ Saran:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.green[700])),
          const SizedBox(height: 4),
          Text(saran, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ]))],
      ),
    );
  }
}
