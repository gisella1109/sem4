import 'package:flutter/material.dart';
import 'dart:io'; // 🔥 Tambahkan ini untuk File
import 'dart:typed_data'; // 🔥 Tambahkan ini untuk Uint8List
import 'blood_sugar_analysis_page.dart';
import 'food_photo_input_page.dart';
import 'health_profile_page.dart';
import 'meal_history_page.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class FoodAnalysisPage extends StatefulWidget {
  final String namaMakanan;
  final String waktuMakan;
  final String? fotoPath;
  final double? porsiGram;
  final String? foodId;
  final Uint8List? imageBytes; 
  final Map<String, dynamic>? foodData; 

  const FoodAnalysisPage({
    super.key,
    required this.namaMakanan,
    required this.waktuMakan,
    this.fotoPath,
    this.porsiGram,
    this.foodId,
    this.imageBytes,
    this.foodData,
  });

  @override
  State<FoodAnalysisPage> createState() => _FoodAnalysisPageState();
}

class _FoodAnalysisPageState extends State<FoodAnalysisPage> {
  int _indeksAktif = 1;
  Map<String, dynamic>? _foodData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFoodData();
  }

  Future<void> _loadFoodData() async {
    final dbHelper = DatabaseHelper.instance;
    Map<String, dynamic>? data;
    
    // Cari berdasarkan foodId atau nama makanan
    if (widget.foodId != null) {
      data = await dbHelper.getFoodById(widget.foodId!);
    } else {
      // Cari berdasarkan nama
      final allFoods = await dbHelper.getAllFoods();
      data = allFoods.firstWhere(
        (food) => food['nama'].toLowerCase() == widget.namaMakanan.toLowerCase(),
        orElse: () => {},
      );
    }
    
    setState(() {
      _foodData = data;
      _isLoading = false;
    });
  }

  Map<String, dynamic> get _nutrisi {
    if (_foodData != null && _foodData!.isNotEmpty) {
      final karbo = (_foodData!['karbo_100g'] as num).toDouble();
      return {
        'kalori': (_foodData!['kalori_100g'] as num).toDouble(),
        'karbo': karbo,
        'protein': (_foodData!['protein_100g'] as num).toDouble(),
        'lemak': (_foodData!['lemak_100g'] as num).toDouble(),
        'status': karbo > 50 ? 'tinggi' : (karbo > 30 ? 'sedang' : 'rendah'),
        'indeks_glikemik': _foodData!['indeks_glikemik'] ?? 50,
        'serat': (_foodData!['serat_100g'] as num?)?.toDouble() ?? 0,
        'gula': (_foodData!['gula_100g'] as num?)?.toDouble() ?? 0,
      };
    }
    
    // Fallback jika data tidak ditemukan
    return {
      'kalori': 350,
      'karbo': 45,
      'protein': 15,
      'lemak': 14,
      'status': 'sedang',
      'indeks_glikemik': 50,
      'serat': 0,
      'gula': 0,
    };
  }

  double get _kaloriPerPorsi {
    final kaloriPer100g = _nutrisi['kalori'] as double;
    final porsiGram = widget.porsiGram ?? 250;
    return (kaloriPer100g * porsiGram / 100);
  }

  double get _karboPerPorsi {
    final karboPer100g = _nutrisi['karbo'] as double;
    final porsiGram = widget.porsiGram ?? 250;
    return (karboPer100g * porsiGram / 100);
  }

  String get _pesanPeringatan {
    final karbo = _nutrisi['karbo'] as double;
    final ig = _nutrisi['indeks_glikemik'] as int;
    
    if (karbo > 50) {
      return 'Makanan ini mengandung karbohidrat tinggi (${karbo.toStringAsFixed(1)}g per 100g). '
             'Indeks Glikemik: $ig (${ig >= 70 ? 'Tinggi' : ig >= 55 ? 'Sedang' : 'Rendah'}). '
             'Disarankan untuk menambah sayuran atau membagi porsi '
             'untuk menjaga gula darah tetap stabil.';
    } else if (karbo > 30) {
      return 'Makanan ini memiliki karbohidrat sedang (${karbo.toStringAsFixed(1)}g per 100g). '
             'Indeks Glikemik: $ig (${ig >= 70 ? 'Tinggi' : ig >= 55 ? 'Sedang' : 'Rendah'}). '
             'Masih aman dikonsumsi, namun perhatikan porsi dan '
             'imbangi dengan aktivitas fisik.';
    } else {
      return 'Makanan ini baik untuk gula darah! Karbohidrat '
             'tergolong rendah (${karbo.toStringAsFixed(1)}g per 100g). '
             'Indeks Glikemik: $ig (${ig >= 70 ? 'Tinggi' : ig >= 55 ? 'Sedang' : 'Rendah'}). '
             'Tetap jaga pola makan sehat.';
    }
  }

  Color get _warnaPeringatan {
    final karbo = _nutrisi['karbo'] as double;
    if (karbo > 50) return const Color(0xFFE65100);
    if (karbo > 30) return const Color(0xFFFFA000);
    return const Color(0xFF4CAF50);
  }

  Color get _warnaIconPeringatan {
    final karbo = _nutrisi['karbo'] as double;
    if (karbo > 50) return Colors.orange;
    if (karbo > 30) return Colors.amber;
    return Colors.green;
  }

  IconData get _ikonPeringatan {
    final karbo = _nutrisi['karbo'] as double;
    if (karbo > 50) return Icons.warning_amber_rounded;
    if (karbo > 30) return Icons.info_outline;
    return Icons.check_circle_outline;
  }

  Future<void> _simpanKeJurnal() async {
    if (_foodData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data makanan tidak ditemukan'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final dbHelper = DatabaseHelper.instance;
    final now = DateTime.now();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final foodLogData = {
      'id': id,
      'food_id': _foodData!['id'],
      'gram': widget.porsiGram ?? 250,
      'waktu_makan': widget.waktuMakan,
      // Simpan nama & nutrisi manual agar riwayat tetap tampil
      // meski food_id tidak cocok di tabel foods
      'nama_manual': _foodData!['nama'] ?? widget.namaMakanan,
      'emoji_manual': _foodData!['emoji'] ?? '🍽',
      'kalori_manual': _kaloriPerPorsi,
      'karbo_manual': ((_foodData!['karbo_100g'] ?? 0) as num).toDouble() * ((widget.porsiGram ?? 250) / 100),
      'gula_manual': ((_foodData!['gula_100g'] ?? 0) as num).toDouble() * ((widget.porsiGram ?? 250) / 100),
      'catatan': null,
      'dicatat_pada': DateFormat('yyyy-MM-dd HH:mm:ss').format(now),
    };
    
    await dbHelper.insertFoodLog(foodLogData);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.namaMakanan} (${(widget.porsiGram ?? 250).toInt()}g) - ${_kaloriPerPorsi.toStringAsFixed(0)} kalori',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2979FF),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MealHistoryPage()),
        (route) => route.isFirst,
      );
    }
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
          'Analisis Makanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF1A1A2E)),
            onPressed: () {
              // TODO: Share analysis
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2979FF)),
                  SizedBox(height: 16),
                  Text('Memuat data nutrisi...'),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildFotoMakanan(),
                  const SizedBox(height: 20),
                  _buildLabelAI(),
                  const SizedBox(height: 8),
                  _buildInfoMakanan(),
                  const SizedBox(height: 20),
                  _buildGridNutrisi(),
                  const SizedBox(height: 16),
                  _buildIndeksGlikemik(),
                  const SizedBox(height: 20),
                  _buildPeringatan(),
                  const SizedBox(height: 28),
                  _buildTombolAksi(),
                  const SizedBox(height: 20),
                  _buildRekomendasi(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      bottomNavigationBar: _buildNavBawah(context),
    );
  }

  Widget _buildFotoMakanan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          children: [
            Container(
              width: double.infinity,
              height: 220,
              color: Colors.amber[100],
              child: widget.fotoPath != null && widget.fotoPath!.isNotEmpty
                  ? (widget.fotoPath!.startsWith('http')
                      ? Image.network(widget.fotoPath!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder())
                      : Image.file(File(widget.fotoPath!), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _buildPlaceholder()))
                  : _buildPlaceholder(),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'AI Analysis',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.porsiGram != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.porsiGram!.toInt()}g',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.orange),
          SizedBox(height: 8),
          Text('Preview Makanan', style: TextStyle(color: Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildLabelAI() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 16, color: Color(0xFF2979FF)),
          SizedBox(width: 6),
          Text(
            'GLUCOGUIDE AI ANALYSIS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2979FF),
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMakanan() {
    final emoji = _foodData?['emoji'] ?? '🍽️';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.namaMakanan,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${(widget.porsiGram ?? 250).toInt()}g • ${widget.waktuMakan} • ${DateFormat('EEEE, d MMM yyyy').format(DateTime.now())}',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          if (_foodData != null)
            Text(
              'Kategori: ${_foodData!['kategori']}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Widget _buildGridNutrisi() {
    final nutrisi = _nutrisi;
    final kaloriPorsi = _kaloriPerPorsi;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _buildKartuNutrisi(kaloriPorsi.toStringAsFixed(0), 'KALORI', Colors.blue, true),
              const SizedBox(width: 10),
              _buildKartuNutrisi(_karboPerPorsi.toStringAsFixed(0), 'KARBO', Colors.orange, true),
              const SizedBox(width: 10),
              _buildKartuNutrisi('${nutrisi['protein'].toStringAsFixed(0)}', 'PROTEIN', Colors.green, false),
              const SizedBox(width: 10),
              _buildKartuNutrisi('${nutrisi['lemak'].toStringAsFixed(0)}', 'LEMAK', Colors.red, false),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Nilai per 100g: Kalori ${nutrisi['kalori'].toStringAsFixed(0)} | '
            'Karbo ${nutrisi['karbo'].toStringAsFixed(1)}g | '
            'Protein ${nutrisi['protein'].toStringAsFixed(1)}g | '
            'Lemak ${nutrisi['lemak'].toStringAsFixed(1)}g',
            style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuNutrisi(String nilai, String label, Color warna, bool isPorsi) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              nilai,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (isPorsi)
              Text(
                'per porsi',
                style: TextStyle(fontSize: 8, color: Colors.grey[400]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndeksGlikemik() {
    final ig = _nutrisi['indeks_glikemik'] as int;
    Color igColor;
    String igStatus;
    
    if (ig >= 70) {
      igColor = Colors.red;
      igStatus = 'Tinggi (Hati-hati)';
    } else if (ig >= 55) {
      igColor = Colors.orange;
      igStatus = 'Sedang (Perhatikan)';
    } else {
      igColor = Colors.green;
      igStatus = 'Rendah (Aman)';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Indeks Glikemik (IG)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: igColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'IG $ig - $igStatus',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: igColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeringatan() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: _warnaPeringatan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _warnaPeringatan.withValues(alpha: 0.3)),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _warnaIconPeringatan.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_ikonPeringatan, color: _warnaIconPeringatan, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (_nutrisi['karbo'] as double) > 50 ? '⚠️ Peringatan Kadar Gula' : 
                    ((_nutrisi['karbo'] as double) > 30 ? '📌 Perhatikan Porsi' : '✅ Rekomendasi Baik'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: _warnaPeringatan,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _pesanPeringatan,
                    style: TextStyle(
                      fontSize: 13,
                      color: _warnaPeringatan,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTombolAksi() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
              ),
              onPressed: _simpanKeJurnal,
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text(
                'Simpan ke Jurnal',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF2979FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                side: BorderSide(color: Colors.grey[300]!),
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodPhotoInputPage(
                      existingNama: widget.namaMakanan,
                      existingWaktu: widget.waktuMakan,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.edit_note_outlined, size: 20),
              label: const Text(
                'Edit Detail',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRekomendasi() {
    final karbo = _nutrisi['karbo'] as double;
    final serat = _nutrisi['serat'] as double;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 20, color: Color(0xFF2979FF)),
                SizedBox(width: 8),
                Text(
                  'Rekomendasi untuk Anda',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (karbo > 30)
              _buildRekomendasiItem(
                '🥗 Kurangi Porsi Karbohidrat',
                'Karbohidrat ${karbo.toStringAsFixed(0)}g per 100g. Coba kurangi porsi nasi/mie menjadi 150g.',
              ),
            if (serat < 2)
              _buildRekomendasiItem(
                '🌿 Tambah Sayuran',
                'Makanan ini rendah serat. Tambahkan sayuran seperti kangkung, bayam, atau brokoli.',
              ),
            _buildRekomendasiItem(
              '💧 Minum Air Putih',
              'Minimal 2 gelas sebelum/sesudah makan untuk membantu pencernaan.',
            ),
            _buildRekomendasiItem(
              '🚶‍♂️ Aktivitas Fisik',
              'Jalan kaki 15-30 menit setelah makan membantu menstabilkan gula darah.',
            ),
            if ((_nutrisi['indeks_glikemik'] as int) >= 70)
              _buildRekomendasiItem(
                '⚠️ Makanan IG Tinggi',
                'Kombinasikan dengan protein dan serat untuk memperlambat penyerapan gula.',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRekomendasiItem(String judul, String deskripsi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            margin: const EdgeInsets.only(top: 8, right: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF2979FF),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 2),
                Text(
                  deskripsi,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBawah(BuildContext context) {
    final daftarMenu = [
      {'ikon': Icons.home_rounded, 'label': 'Beranda', 'halaman': null},
      {'ikon': Icons.bar_chart_rounded, 'label': 'Laporan', 'halaman': const BloodSugarAnalysisPage()},
      {'ikon': null, 'label': 'Tambah', 'halaman': const FoodPhotoInputPage()},
      {'ikon': Icons.history_rounded, 'label': 'Riwayat', 'halaman': const MealHistoryPage()},
      {'ikon': Icons.person_outline_rounded, 'label': 'Profil', 'halaman': const HealthProfilePage()},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(daftarMenu.length, (i) {
          final menu = daftarMenu[i];
          
          if (i == 2) {
            return GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const FoodPhotoInputPage()),
                );
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2979FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x442979FF),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          }

          final aktif = _indeksAktif == i;
          return GestureDetector(
            onTap: () {
              setState(() => _indeksAktif = i);
              if (menu['halaman'] != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => menu['halaman'] as Widget),
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  menu['ikon'] as IconData,
                  color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(height: 3),
                Text(
                  menu['label'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                    fontWeight: aktif ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}