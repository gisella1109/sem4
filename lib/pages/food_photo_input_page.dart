import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart';
import 'food_analysis_page.dart';
import '../database/database_helper.dart';
import '../services/food_recognition_service.dart';

class FoodPhotoInputPage extends StatefulWidget {
  final String? existingNama;
  final String? existingWaktu;
  
  const FoodPhotoInputPage({super.key, this.existingNama, this.existingWaktu});

  @override
  State<FoodPhotoInputPage> createState() => _FoodPhotoInputPageState();
}

class _FoodPhotoInputPageState extends State<FoodPhotoInputPage> {
  final _searchController = TextEditingController();
  int _waktuMakanDipilih = 0;
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  double _porsiGram = 250;
  bool _isLoading = false;
  bool _isSearching = false;
  
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _selectedFood;
  
  // 🔥 Tambahkan service untuk AI
  final FoodRecognitionService _foodService = FoodRecognitionService();
  
  final List<Map<String, dynamic>> _daftarWaktuMakan = const [
    {'label': 'Sarapan', 'ikon': Icons.wb_sunny_outlined, 'waktu': '06:00-09:00'},
    {'label': 'Siang', 'ikon': Icons.wb_sunny, 'waktu': '11:00-13:00'},
    {'label': 'Malam', 'ikon': Icons.dark_mode, 'waktu': '18:00-20:00'},
    {'label': 'Cemilan', 'ikon': Icons.cookie_outlined, 'waktu': '10:00 & 15:00'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingNama != null) {
      _searchController.text = widget.existingNama!;
      _searchFood();
    }
    if (widget.existingWaktu != null) {
      final index = _daftarWaktuMakan.indexWhere(
        (item) => item['label'] == widget.existingWaktu
      );
      if (index != -1) _waktuMakanDipilih = index;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchFood() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    
    setState(() => _isSearching = true);
    
    final dbHelper = DatabaseHelper.instance;
    final results = await dbHelper.searchFoods(query);
    
    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF2979FF)),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _ambilFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF2979FF)),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _ambilFoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // 🔥 Method untuk mengambil foto (sudah termasuk analisis AI)
  Future<void> _ambilFoto(ImageSource source) async {
    try {
      final XFile? foto = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (foto != null) {
        setState(() {
          _selectedImage = foto;
          _isLoading = true;
        });
        
        // 🔥 LANGSUNG ANALISIS FOTO
        await _analyzeFoodFromPhoto(foto);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengambil foto'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // 🔥 Method untuk analisis foto dengan AI
  Future<void> _analyzeFoodFromPhoto(XFile photo) async {
    try {
      File imageFile = File(photo.path);
      
      // 🔥 AI mendeteksi makanan dan nutrisi dari foto
      final result = await _foodService.analyzeFoodFromPhoto(imageFile);
      
      if (result != null && mounted) {
        setState(() {
          _searchController.text = result['nama'];
          _selectedFood = {
            'id': result['nama'].toLowerCase().replaceAll(' ', '_'),
            'nama': result['nama'],
            'emoji': _getEmojiForFood(result['nama']),
            'kalori_100g': result['kalori'],
            'karbo_100g': result['karbo'],
            'protein_100g': result['protein'],
            'lemak_100g': result['lemak'],
            'serat_100g': result['serat'] ?? 0,
            'gula_100g': result['gula'] ?? 0,
            'kategori': _getCategoryForFood(result['nama']),
            'indeks_glikemik': _estimateGI(result['karbo']),
          };
          _searchResults = [];
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ AI mendeteksi: ${result['nama']} | ${result['kalori'].toInt()} kalori per 100g'),
            backgroundColor: const Color(0xFF2979FF),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat mengenali makanan, silakan cari manual'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error analyzing food: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menganalisis foto, coba lagi'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String _getEmojiForFood(String foodName) {
    if (foodName.contains('Nasi')) return '🍚';
    if (foodName.contains('Ayam')) return '🍗';
    if (foodName.contains('Mie')) return '🍜';
    if (foodName.contains('Soto')) return '🍲';
    if (foodName.contains('Goreng')) return '🍳';
    if (foodName.contains('Bakar')) return '🔥';
    if (foodName.contains('Tahu') || foodName.contains('Tempe')) return '🟫';
    if (foodName.contains('Sayur')) return '🥬';
    if (foodName.contains('Buah')) return '🍎';
    return '🍽️';
  }

  String _getCategoryForFood(String foodName) {
    if (foodName.contains('Nasi') || foodName.contains('Mie') || foodName.contains('Roti')) return 'makanan_pokok';
    if (foodName.contains('Ayam') || foodName.contains('Daging') || foodName.contains('Ikan') || foodName.contains('Telur')) return 'protein';
    if (foodName.contains('Sayur')) return 'sayuran';
    if (foodName.contains('Buah')) return 'buah';
    return 'masakan';
  }

  int _estimateGI(double karbo) {
    if (karbo > 50) return 70;
    if (karbo > 30) return 55;
    return 40;
  }

  Future<Uint8List?> _getImageBytes() async {
    if (_selectedImage == null) return null;
    return await _selectedImage!.readAsBytes();
  }

  void _pilihMakanan(Map<String, dynamic> food) {
    setState(() {
      _selectedFood = food;
      _searchController.text = food['nama'];
      _searchResults = [];
    });
  }

  Future<void> _simpanDanAnalisis() async {
    if (_selectedFood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih makanan dari hasil pencarian'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final imageBytes = await _getImageBytes();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FoodAnalysisPage(
          namaMakanan: _selectedFood!['nama'],
          waktuMakan: _daftarWaktuMakan[_waktuMakanDipilih]['label'] as String,
          porsiGram: _porsiGram,
          foodId: _selectedFood!['id'],
          imageBytes: imageBytes,
          foodData: _selectedFood,
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImage == null) {
      return Container(
        color: Colors.amber[100],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.restaurant, size: 80, color: Colors.orange),
              SizedBox(height: 8),
              Text('Preview Makanan', style: TextStyle(color: Colors.orange)),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<Uint8List?>(
      future: _selectedImage!.readAsBytes(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.memory(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 220,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.amber[100],
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 50, color: Colors.orange),
                        SizedBox(height: 8),
                        Text('Gagal memuat gambar'),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        
        if (snapshot.hasError) {
          return Container(
            color: Colors.amber[100],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50, color: Colors.red),
                  SizedBox(height: 8),
                  Text('Gagal memuat gambar'),
                ],
              ),
            ),
          );
        }
        
        return Container(
          color: Colors.amber[100],
          child: const Center(
            child: CircularProgressIndicator(color: Color(0xFF2979FF)),
          ),
        );
      },
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
          'Input Foto Makanan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2979FF)),
                  SizedBox(height: 16),
                  Text('AI sedang menganalisis foto...'),
                  SizedBox(height: 8),
                  Text('Mohon tunggu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildFotoUpload(),
                  const SizedBox(height: 16),
                  _buildTombolFoto(),
                  const SizedBox(height: 20),
                  _buildPencarianMakanan(),
                  const SizedBox(height: 16),
                  if (_searchResults.isNotEmpty) _buildHasilPencarian(),
                  const SizedBox(height: 16),
                  if (_selectedFood != null) _buildMakananTerpilih(),
                  const SizedBox(height: 20),
                  _buildPorsiSlider(),
                  const SizedBox(height: 20),
                  _buildWaktuMakan(),
                  const SizedBox(height: 24),
                  _buildTombolSimpan(),
                  const SizedBox(height: 10),
                  _buildKeteranganAI(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildFotoUpload() {
    final bool hasImage = _selectedImage != null;
    
    return GestureDetector(
      onTap: _showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF2979FF).withValues(alpha: 0.35),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  _buildImagePreview(),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 18, color: Colors.grey),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Ganti', style: TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2979FF).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF2979FF), size: 30),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Ambil atau Pilih Foto',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'AI akan mendeteksi makanan & kalori dari foto Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.5),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTombolFoto() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => _ambilFoto(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined, size: 20),
            label: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF1A1A2E),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              side: BorderSide(color: Colors.grey[300]!),
              backgroundColor: Colors.white,
            ),
            onPressed: () => _ambilFoto(ImageSource.gallery),
            icon: const Icon(Icons.photo_library_outlined, size: 20),
            label: const Text('Galeri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildPencarianMakanan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Atau Cari Manual',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari: Nasi Goreng, Ayam Bakar, ...',
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: _isSearching
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchResults = [];
                          _selectedFood = null;
                        });
                      },
                    ),
            ),
            onChanged: (value) => _searchFood(),
          ),
        ),
      ],
    );
  }

  Widget _buildHasilPencarian() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _searchResults.map((food) {
          return ListTile(
            leading: Text(food['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 24)),
            title: Text(food['nama']),
            subtitle: Text(
              '${food['kalori_100g']} kalori/100g • ${food['karbo_100g']}g karbo',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF2979FF)),
            onTap: () => _pilihMakanan(food),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMakananTerpilih() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2979FF), width: 1),
      ),
      child: Row(
        children: [
          Text(_selectedFood!['emoji'] ?? '🍽️', style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFood!['nama'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${_selectedFood!['kalori_100g']} kal/100g • ${_selectedFood!['karbo_100g']}g karbo • IG: ${_selectedFood!['indeks_glikemik']}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2979FF)),
            onPressed: () {
              setState(() {
                _selectedFood = null;
                _searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPorsiSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Perkiraan Porsi',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_porsiGram.toInt()} gram',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2979FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: _porsiGram,
          min: 50,
          max: 500,
          divisions: 9,
          activeColor: const Color(0xFF2979FF),
          inactiveColor: Colors.grey[300],
          label: '${_porsiGram.toInt()} gram',
          onChanged: (value) => setState(() => _porsiGram = value),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Kecil', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text('Sedang', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            Text('Besar', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
      ],
    );
  }

  Widget _buildWaktuMakan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Waktu Makan',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
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
                  border: Border.all(
                    color: dipilih ? const Color(0xFF2979FF) : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _daftarWaktuMakan[i]['ikon'] as IconData,
                      size: 20,
                      color: dipilih ? const Color(0xFF2979FF) : Colors.grey[500],
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _daftarWaktuMakan[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                            color: dipilih ? const Color(0xFF2979FF) : Colors.grey[600],
                          ),
                        ),
                        Text(
                          _daftarWaktuMakan[i]['waktu'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            color: dipilih ? const Color(0xFF2979FF).withValues(alpha: 0.7) : Colors.grey[400],
                          ),
                        ),
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

  Widget _buildTombolSimpan() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2979FF),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        onPressed: _simpanDanAnalisis,
        child: const Text(
          'Simpan & Analisis',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildKeteranganAI() {
    return Center(
      child: Text(
        '📸 Ambil foto makanan → AI akan mendeteksi nama & kalori\n🔍 Atau cari manual dari database kami',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
          height: 1.5,
        ),
      ),
    );
  }
}