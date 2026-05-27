import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/food_journal.dart';
import '../services/api_service.dart';
import 'food_analysis_page.dart';
class CatatanMakananManualPage extends StatefulWidget {
  const CatatanMakananManualPage({super.key});

  @override
  State<CatatanMakananManualPage> createState() =>
      _CatatanMakananManualPageState();
}

class _CatatanMakananManualPageState
    extends State<CatatanMakananManualPage> {
  final _searchController = TextEditingController();

  int _jumlahPorsi = 1;       // 1–5
  int _waktuMakanDipilih = 0;
  bool _isSearching = false;

  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;

  final List<Map<String, dynamic>> _daftarWaktuMakan = const [
    {'label': 'Sarapan', 'ikon': Icons.wb_sunny_outlined,  'waktu': '06:00-09:00'},
    {'label': 'Siang',   'ikon': Icons.wb_sunny,            'waktu': '11:00-13:00'},
    {'label': 'Malam',   'ikon': Icons.dark_mode,           'waktu': '18:00-20:00'},
    {'label': 'Cemilan', 'ikon': Icons.cookie_outlined,     'waktu': '10:00 & 15:00'},
  ];

  // ── Mapping satuan & gram-per-satuan berdasarkan makanan ──
  Map<String, dynamic> _getSatuan(Map<String, dynamic> food) {
    final nama = (food['nama'] as String).toLowerCase();
    final kategori = (food['kategori'] as String).toLowerCase();

    // Masakan berkuah → mangkuk
    if (nama.contains('soto') || nama.contains('bakso') ||
        nama.contains('sup') || nama.contains('rawon') ||
        nama.contains('opor') || nama.contains('gulai') ||
        nama.contains('sop')) {
      return {'satuan': 'mangkuk', 'ikon': '🥣', 'gram': 350.0};
    }

    // Makanan pokok / nasi / mie → piring
    if (nama.contains('nasi') || nama.contains('mie') ||
        nama.contains('bihun') || nama.contains('lontong') ||
        nama.contains('ketupat') || nama.contains('gado') ||
        nama.contains('goreng') || nama.contains('bakar') ||
        nama.contains('rendang') || nama.contains('pecel') ||
        kategori == 'masakan') {
      return {'satuan': 'piring', 'ikon': '🍽️', 'gram': 300.0};
    }

    // Roti → lembar
    if (nama.contains('roti')) {
      return {'satuan': 'lembar', 'ikon': '🍞', 'gram': 35.0};
    }

    // Telur → butir
    if (nama.contains('telur')) {
      return {'satuan': 'butir', 'ikon': '🥚', 'gram': 55.0};
    }

    // Buah besar (per buah)
    if (nama.contains('pisang') || nama.contains('apel') ||
        nama.contains('jeruk') || nama.contains('mangga') ||
        nama.contains('pepaya') || nama.contains('alpukat')) {
      return {'satuan': 'buah', 'ikon': '🍎', 'gram': 120.0};
    }

    // Buah biji kecil (anggur, dll)
    if (nama.contains('anggur') || nama.contains('semangka')) {
      return {'satuan': 'biji', 'ikon': '🍇', 'gram': 15.0};
    }

    // Tahu tempe → potong
    if (nama.contains('tahu') || nama.contains('tempe')) {
      return {'satuan': 'potong', 'ikon': '🟫', 'gram': 50.0};
    }

    // Ayam / daging / ikan → potong
    if (kategori == 'protein' || nama.contains('ayam') ||
        nama.contains('daging') || nama.contains('ikan') ||
        nama.contains('udang')) {
      return {'satuan': 'potong', 'ikon': '🍗', 'gram': 80.0};
    }

    // Sayuran → porsi
    if (kategori == 'sayuran') {
      return {'satuan': 'porsi', 'ikon': '🥬', 'gram': 100.0};
    }

    // Default → porsi
    return {'satuan': 'porsi', 'ikon': '🍽️', 'gram': 150.0};
  }

  // ── Hitung total gram dari jumlah porsi ───────────────────
  double get _totalGram {
    if (_selectedFood == null) return 0;
    final gramPerSatuan = _getSatuan(_selectedFood!)['gram'] as double;
    return gramPerSatuan * _jumlahPorsi;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() { _searchResults = []; _isSearching = false; });
      return;
    }
    setState(() => _isSearching = true);
    final results = await DatabaseHelper.instance.searchFoods(query);
    setState(() { _searchResults = results; _isSearching = false; });
  }

  void _pilihMakanan(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _jumlahPorsi = 1;
      _searchController.text = food['nama'];
      _searchResults = [];
    });
  }

  Future<void> _simpanDanAnalisis() async {
  if (_selectedFood == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Silakan pilih makanan terlebih dahulu'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  // HITUNG NUTRISI
  final kalori =
      (_selectedFood!['kalori_100g'] as num) *
      _totalGram / 100;

  final karbo =
      (_selectedFood!['karbo_100g'] as num) *
      _totalGram / 100;

  final protein =
      (_selectedFood!['protein_100g'] as num) *
      _totalGram / 100;

  final lemak =
      (_selectedFood!['lemak_100g'] as num) *
      _totalGram / 100;

  // BUAT OBJECT JURNAL
  final jurnal = JurnalMakanan(
  id: '',
  namaMakanan: _selectedFood!['nama'],
  foodId: _selectedFood!['id'].toString(),
  gram: _totalGram,
  waktuMakan:
      _daftarWaktuMakan[_waktuMakanDipilih]['label'] as String,
  kalori: ((_selectedFood!['kalori_100g'] as num) * _totalGram / 100)
      .toDouble(),
  karbo: ((_selectedFood!['karbo_100g'] as num) * _totalGram / 100)
      .toDouble(),
  protein:
      ((_selectedFood!['protein_100g'] as num) * _totalGram / 100)
          .toDouble(),
  lemak:
      ((_selectedFood!['lemak_100g'] as num) * _totalGram / 100)
          .toDouble(),
  serat:
      ((_selectedFood!['serat_100g'] as num?)?.toDouble() ?? 0),
  gula:
      ((_selectedFood!['gula_100g'] as num?)?.toDouble() ?? 0),
  fotoPath: null,
  dicatatPada: DateTime.now(),
  indeksGlikemik:
      (_selectedFood!['indeks_glikemik'] as num?)?.toInt() ?? 50,
);

await ApiService.saveFoodLog(jurnal);
  if (berhasil) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Berhasil disimpan ke database'),
        backgroundColor: Colors.green,
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal simpan ke database'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // PINDAH HALAMAN
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => FoodAnalysisPage(
        namaMakanan: _selectedFood!['nama'],
        waktuMakan:
            _daftarWaktuMakan[_waktuMakanDipilih]['label']
                as String,
        porsiGram: _totalGram,
        foodId: _selectedFood!['id'],
        imageBytes: null,
        foodData: _selectedFood,
      ),
    ),
  );
}

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
        title: const Text(
          'Catat Makanan Manual',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildBanner(),
            const SizedBox(height: 20),
            _buildPencarian(),
            const SizedBox(height: 12),
            if (_searchResults.isNotEmpty) _buildHasilPencarian(),
            if (_selectedFood != null) ...[
              const SizedBox(height: 8),
              _buildMakananTerpilih(),
              const SizedBox(height: 20),
              _buildPilihPorsi(),
            ],
            const SizedBox(height: 20),
            _buildWaktuMakan(),
            const SizedBox(height: 24),
            _buildTombolSimpan(),
            const SizedBox(height: 10),
            Center(
              child: Text(
                '🔍 Cari makanan → pilih jumlah → kalori dihitung otomatis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── Banner ────────────────────────────────────────────────
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -20,
            child: Container(width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), shape: BoxShape.circle))),
          Positioned(bottom: -30, left: -10,
            child: Container(width: 120, height: 120,
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.edit_note_rounded, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Input Manual', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 6),
                      Text(
                        'Cari makanan → pilih jumlah piring/mangkuk/biji → kalori dihitung otomatis',
                        style: TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12, right: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calculate_outlined, size: 13, color: Colors.white),
                  SizedBox(width: 4),
                  Text('Auto Hitung', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Pencarian ─────────────────────────────────────────────
  Widget _buildPencarian() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cari Makanan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari: Nasi Goreng, Bakso, Ayam Bakar...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              filled: true, fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _isSearching
                  ? const Padding(padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                  : _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() { _searchResults = []; _selectedFood = null; });
                          })
                      : null,
            ),
            onChanged: (_) => _searchFood(),
          ),
        ),
      ],
    );
  }

  // ── Hasil pencarian ───────────────────────────────────────
  Widget _buildHasilPencarian() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: _searchResults.map((food) {
          final satuan = _getSatuan(food);
          return ListTile(
            leading: Text(food['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 24)),
            title: Text(food['nama'], style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              '${food['kalori_100g']} kal/100g  •  per ${satuan['satuan']}: ~${(satuan['gram'] as double).toInt()}g',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(satuan['ikon'] as String, style: const TextStyle(fontSize: 16)),
            ),
            onTap: () => _pilihMakanan(food),
          );
        }).toList(),
      ),
    );
  }

  // ── Makanan terpilih ──────────────────────────────────────
  Widget _buildMakananTerpilih() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2979FF), width: 1.5),
      ),
      child: Row(
        children: [
          Text(_selectedFood!['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedFood!['nama'],
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A2340))),
                Text(
                  '${_selectedFood!['kalori_100g']} kal/100g  •  IG: ${_selectedFood!['indeks_glikemik']}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2979FF), size: 20),
            onPressed: () => setState(() { _selectedFood = null; _searchController.clear(); }),
          ),
        ],
      ),
    );
  }

  // ── Pilih porsi (1–5 dengan satuan alami) ─────────────────
  Widget _buildPilihPorsi() {
    if (_selectedFood == null) return const SizedBox();

    final satuan    = _getSatuan(_selectedFood!);
    final namaS     = satuan['satuan'] as String;
    final ikonS     = satuan['ikon'] as String;
    final gramPerS  = satuan['gram'] as double;
    final totalGram = gramPerS * _jumlahPorsi;

    // Hitung nutrisi preview
    final kalori  = (_selectedFood!['kalori_100g']  as num) * totalGram / 100;
    final karbo   = (_selectedFood!['karbo_100g']   as num) * totalGram / 100;
    final protein = (_selectedFood!['protein_100g'] as num) * totalGram / 100;
    final lemak   = (_selectedFood!['lemak_100g']   as num) * totalGram / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(ikonS, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              'Berapa $namaS?',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '~${totalGram.toInt()} gram',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2979FF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Tombol pilih jumlah 1–5
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(5, (i) {
            final angka   = i + 1;
            final dipilih = _jumlahPorsi == angka;
            return GestureDetector(
              onTap: () => setState(() => _jumlahPorsi = angka),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 56, height: 72,
                decoration: BoxDecoration(
                  color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: dipilih ? const Color(0xFF2979FF) : Colors.grey.shade300,
                    width: dipilih ? 2 : 1,
                  ),
                  boxShadow: dipilih
                      ? [const BoxShadow(color: Color(0x442979FF), blurRadius: 10, offset: Offset(0, 4))]
                      : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(ikonS, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      '$angka',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: dipilih ? Colors.white : const Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 6),
        Center(
          child: Text(
            '$_jumlahPorsi $namaS  ≈  ${totalGram.toInt()} gram',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),

        // Preview nutrisi
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _previewNutrisi('${kalori.toStringAsFixed(0)}', 'KALORI', Colors.blue),
              _divider(),
              _previewNutrisi('${karbo.toStringAsFixed(1)}g', 'KARBO', Colors.orange),
              _divider(),
              _previewNutrisi('${protein.toStringAsFixed(1)}g', 'PROTEIN', Colors.green),
              _divider(),
              _previewNutrisi('${lemak.toStringAsFixed(1)}g', 'LEMAK', Colors.red),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'per $_jumlahPorsi $namaS (${totalGram.toInt()}g)',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  // ── Waktu makan ───────────────────────────────────────────
  Widget _buildWaktuMakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Waktu Makan',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10, mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.5,
          children: List.generate(_daftarWaktuMakan.length, (i) {
            final dipilih = _waktuMakanDipilih == i;
            return GestureDetector(
              onTap: () => setState(() => _waktuMakanDipilih = i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: dipilih ? const Color(0xFFEAF2FF) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: dipilih ? const Color(0xFF2979FF) : Colors.transparent, width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_daftarWaktuMakan[i]['ikon'] as IconData, size: 20,
                        color: dipilih ? const Color(0xFF2979FF) : Colors.grey[500]),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_daftarWaktuMakan[i]['label'] as String,
                            style: TextStyle(fontSize: 14,
                                fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                                color: dipilih ? const Color(0xFF2979FF) : Colors.grey[600])),
                        Text(_daftarWaktuMakan[i]['waktu'] as String,
                            style: TextStyle(fontSize: 10,
                                color: dipilih ? const Color(0xFF2979FF).withOpacity(0.7) : Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Tombol simpan ─────────────────────────────────────────
  Widget _buildTombolSimpan() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2979FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          shadowColor: const Color(0x442979FF),
        ),
        onPressed: _simpanDanAnalisis,
        icon: const Icon(Icons.save_outlined, size: 20),
        label: const Text('Simpan & Analisis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _previewNutrisi(String nilai, String label, Color warna) {
    return Column(
      children: [
        Text(nilai, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: warna)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w600, letterSpacing: 0.5)),
      ],
    );
  }

  Widget _divider() => Container(width: 1, height: 30, color: Colors.grey[200]);
}