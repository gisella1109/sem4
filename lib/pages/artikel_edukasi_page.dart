import 'package:flutter/material.dart';
import '../models/artikel_model.dart';

class ArtikelEdukasiPage extends StatefulWidget {
  const ArtikelEdukasiPage({super.key});

  @override
  State<ArtikelEdukasiPage> createState() => _ArtikelEdukasiPageState();
}

class _ArtikelEdukasiPageState extends State<ArtikelEdukasiPage> {
  String _kategoriDipilih = 'Semua';
  final List<String> _daftarKategori = ['Semua', 'Dasar', 'Nutrisi', 'Monitoring', 'Gaya Hidup'];

  List<Artikel> get _artikelFiltered => _kategoriDipilih == 'Semua'
      ? daftarArtikel
      : daftarArtikel.where((a) => a.kategori == _kategoriDipilih).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edukasi Diabetes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner nutrisi singkat
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: GestureDetector(
              onTap: () => _showTabelNutrisi(context),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('🍽', style: TextStyle(fontSize: 32)),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Panduan Nutrisi Diabetes',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Kalori • Karbo • Gula • Serat • Protein',
                              style: TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ),
          ),

          // Filter kategori
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
                  onTap: () => setState(() => _kategoriDipilih = kat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!),
                    ),
                    child: Text(kat,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: dipilih ? Colors.white : Colors.grey[600])),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Daftar artikel
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _artikelFiltered.length,
              itemBuilder: (context, i) => _buildKartuArtikel(context, _artikelFiltered[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuArtikel(BuildContext context, Artikel artikel) {
    final Color warnaKategori = _warnaKategori(artikel.kategori);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailArtikelPage(artikel: artikel)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                artikel.gambar,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 140,
                  color: warnaKategori.withValues(alpha: 0.1),
                  child: Center(child: Text('📖', style: const TextStyle(fontSize: 48))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: warnaKategori.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(artikel.kategori,
                            style: TextStyle(fontSize: 11, color: warnaKategori, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(artikel.duraBaca, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(artikel.judul,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 6),
                  Text(
                    artikel.isi.split('\n').first,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _warnaKategori(String kat) {
    switch (kat) {
      case 'Nutrisi': return const Color(0xFF2979FF);
      case 'Monitoring': return Colors.green;
      case 'Gaya Hidup': return Colors.orange;
      case 'Dasar': return Colors.purple;
      default: return Colors.grey;
    }
  }

  void _showTabelNutrisi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TabelNutrisiSheet(),
    );
  }
}

// ==================== TABEL NUTRISI SHEET ====================
class TabelNutrisiSheet extends StatelessWidget {
  const TabelNutrisiSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            const Text('Panduan Nutrisi Diabetes',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('Fungsi dan efek pada gula darah',
                style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: const [
                  _ItemNutrisi(
                    emoji: '🔥',
                    nama: 'Kalori',
                    warna: Color(0xFFFF6B35),
                    fungsi: 'Sumber energi tubuh',
                    efek: 'Kelebihan kalori menyebabkan kenaikan berat badan dan memperburuk resistensi insulin',
                    saran: 'Sesuaikan dengan kebutuhan harian (1500–2000 kkal untuk dewasa)',
                  ),
                  _ItemNutrisi(
                    emoji: '🌾',
                    nama: 'Karbohidrat',
                    warna: Color(0xFFFF8C00),
                    fungsi: 'Sumber energi utama',
                    efek: 'Dicerna menjadi glukosa, meningkatkan gula darah secara langsung',
                    saran: 'Pilih karbohidrat kompleks: nasi merah, ubi, oatmeal',
                  ),
                  _ItemNutrisi(
                    emoji: '🍬',
                    nama: 'Gula',
                    warna: Color(0xFFE53935),
                    fungsi: 'Jenis karbohidrat sederhana (bagian dari karbo)',
                    efek: 'Meningkatkan gula darah dengan sangat cepat — perlu dibatasi ketat',
                    saran: 'Maksimal 25g per hari. Hindari minuman manis dan kue',
                  ),
                  _ItemNutrisi(
                    emoji: '🥦',
                    nama: 'Serat',
                    warna: Color(0xFF43A047),
                    fungsi: 'Membantu pencernaan',
                    efek: 'Memperlambat penyerapan glukosa, membantu mengontrol gula darah',
                    saran: 'Konsumsi 25–30g per hari dari sayuran, buah, dan biji-bijian',
                  ),
                  _ItemNutrisi(
                    emoji: '🍗',
                    nama: 'Protein',
                    warna: Color(0xFF2979FF),
                    fungsi: 'Membangun dan memperbaiki jaringan tubuh',
                    efek: 'Tidak langsung mempengaruhi gula darah, membantu rasa kenyang lebih lama',
                    saran: 'Pilih protein rendah lemak: ikan, ayam tanpa kulit, tahu, tempe',
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemNutrisi extends StatelessWidget {
  final String emoji;
  final String nama;
  final Color warna;
  final String fungsi;
  final String efek;
  final String saran;

  const _ItemNutrisi({
    required this.emoji,
    required this.nama,
    required this.warna,
    required this.fungsi,
    required this.efek,
    required this.saran,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: warna.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: warna.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
        ),
        title: Text(nama, style: TextStyle(fontWeight: FontWeight.bold, color: warna, fontSize: 15)),
        subtitle: Text(fungsi, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        iconColor: warna,
        collapsedIconColor: Colors.grey[400],
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _baris('⚡ Efek pada gula darah', efek, const Color(0xFFE53935)),
                const SizedBox(height: 8),
                _baris('✅ Saran konsumsi', saran, const Color(0xFF43A047)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _baris(String label, String nilai, Color warna) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: warna)),
        const SizedBox(height: 4),
        Text(nilai, style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
      ],
    );
  }
}

// ==================== DETAIL ARTIKEL ====================
class DetailArtikelPage extends StatelessWidget {
  final Artikel artikel;
  const DetailArtikelPage({super.key, required this.artikel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF2979FF),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    artikel.gambar,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2979FF)),
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2979FF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(artikel.kategori,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(artikel.duraBaca, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(artikel.judul,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _buildIsiArtikel(artikel.isi),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIsiArtikel(String isi) {
    final paragraf = isi.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraf.map((baris) {
        if (baris.isEmpty) return const SizedBox(height: 8);
        // Header (semua huruf besar)
        if (baris == baris.toUpperCase() && baris.trim().isNotEmpty && !baris.startsWith('•') && !baris.startsWith('✅') && !baris.startsWith('❌') && !baris.startsWith('⚠') && !baris.startsWith('─')) {
          return Padding(
            padding: const EdgeInsets.only(top: 16, bottom: 6),
            child: Text(baris,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF2979FF), letterSpacing: 0.5)),
          );
        }
        // Pemisah
        if (baris.startsWith('─')) return const Padding(padding: EdgeInsets.symmetric(vertical: 4), child: Divider());
        // Bullet
        if (baris.startsWith('•') || baris.startsWith('✅') || baris.startsWith('❌') || baris.startsWith('⚠️')) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6, left: 4),
            child: Text(baris, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.5)),
          );
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(baris, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.6)),
        );
      }).toList(),
    );
  }
}

// ==================== WIDGET POPUP NUTRISI (untuk halaman input) ====================
class PopupInfoNutrisi extends StatelessWidget {
  final String namaMakanan;
  final double kalori;
  final double karbo;
  final double gula;
  final double serat;
  final double protein;

  const PopupInfoNutrisi({
    super.key,
    required this.namaMakanan,
    required this.kalori,
    required this.karbo,
    required this.gula,
    required this.serat,
    required this.protein,
  });

  static void show(BuildContext context, {
    required String namaMakanan,
    required double kalori,
    required double karbo,
    double gula = 0,
    double serat = 0,
    required double protein,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PopupInfoNutrisi(
        namaMakanan: namaMakanan,
        kalori: kalori,
        karbo: karbo,
        gula: gula,
        serat: serat,
        protein: protein,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          Text('Info Nutrisi', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          Text(namaMakanan, style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const SizedBox(height: 16),
          Row(
            children: [
              _chipNutrisi('🔥', '${kalori.toStringAsFixed(0)}', 'kkal', const Color(0xFFFF6B35)),
              const SizedBox(width: 8),
              _chipNutrisi('🌾', '${karbo.toStringAsFixed(1)}g', 'karbo', const Color(0xFFFF8C00)),
              const SizedBox(width: 8),
              _chipNutrisi('🍗', '${protein.toStringAsFixed(1)}g', 'protein', const Color(0xFF2979FF)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _chipNutrisi('🍬', '${gula.toStringAsFixed(1)}g', 'gula', const Color(0xFFE53935)),
              const SizedBox(width: 8),
              _chipNutrisi('🥦', '${serat.toStringAsFixed(1)}g', 'serat', const Color(0xFF43A047)),
              const SizedBox(width: 8),
              Expanded(child: const SizedBox()),
            ],
          ),
          if (gula > 15) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('⚠️', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('Kandungan gula tinggi. Batasi konsumsi untuk mengontrol gula darah.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE65100))),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _chipNutrisi(String emoji, String nilai, String label, Color warna) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: warna.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: warna.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 2),
            Text(nilai, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warna)),
            Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}