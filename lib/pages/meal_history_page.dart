import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';

class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key});

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  List<Map<String, dynamic>> _riwayat = [];
  bool _isLoading = true;
  double _totalKalori = 0;
  double _totalKarbo = 0;
  double _totalGula = 0;

  // Batas gula harian untuk penderita diabetes (Kemenkes/WHO)
  static const double _batasGulaHarian = 25.0; // gram/hari

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    setState(() => _isLoading = true);
    try {
      final rawList = await _getLogsWithFoodInfo();
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      double totalKal = 0, totalKarbo = 0, totalGula = 0;
      for (final r in rawList) {
        final logDate = r['dicatat_pada']?.toString().substring(0, 10) ?? '';
        if (logDate == today) {
          totalKal += (r['total_kalori'] as num?)?.toDouble() ?? 0;
          totalKarbo += (r['total_karbo'] as num?)?.toDouble() ?? 0;
          totalGula += (r['total_gula'] as num?)?.toDouble() ?? 0;
        }
      }

      setState(() {
        _riwayat = rawList;
        _totalKalori = totalKal;
        _totalKarbo = totalKarbo;
        _totalGula = totalGula;
        _isLoading = false;
      });

      // Cek apakah gula melebihi batas
      if (totalGula > _batasGulaHarian) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _showPeringatanGula(totalGula));
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat riwayat: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getLogsWithFoodInfo() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT 
        l.id,
        l.gram,
        l.waktu_makan,
        l.dicatat_pada,
        l.foto_bytes,
        COALESCE(l.nama_manual, f.nama, 'Makanan') AS nama_tampil,
        COALESCE(l.emoji_manual, f.emoji, '🍽') AS emoji,
        COALESCE(
          CASE WHEN l.kalori_manual IS NOT NULL THEN l.kalori_manual
               WHEN f.kalori_100g IS NOT NULL THEN f.kalori_100g * l.gram / 100
               ELSE 0 END, 0) AS total_kalori,
        COALESCE(
          CASE WHEN l.karbo_manual IS NOT NULL THEN l.karbo_manual
               WHEN f.karbo_100g IS NOT NULL THEN f.karbo_100g * l.gram / 100
               ELSE 0 END, 0) AS total_karbo,
        COALESCE(
          CASE WHEN l.gula_manual IS NOT NULL THEN l.gula_manual
               WHEN f.gula_100g IS NOT NULL THEN f.gula_100g * l.gram / 100
               ELSE 0 END, 0) AS total_gula,
        f.indeks_glikemik
      FROM food_log l
      LEFT JOIN foods f ON l.food_id = f.id
      ORDER BY l.dicatat_pada DESC
    ''');
    return results;
  }

  void _showPeringatanGula(double totalGula) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Peringatan Gula', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gula hari ini ${totalGula.toStringAsFixed(1)}g melebihi batas harian untuk penderita diabetes.',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batas gula harian (Kemenkes/WHO):',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE65100))),
                  const SizedBox(height: 6),
                  _barisInfo('Penderita diabetes', '≤ 25g/hari', const Color(0xFFE53935)),
                  _barisInfo('Orang normal', '≤ 50g/hari', Colors.orange),
                  const SizedBox(height: 6),
                  Text('Total kamu hari ini: ${totalGula.toStringAsFixed(1)}g',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFE53935))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tips: Kurangi makanan manis, minuman bergula, dan buah tinggi gula untuk sisa hari ini.',
                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _barisInfo(String label, String nilai, Color warna) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text('• $label: ', style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          Text(nilai, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: warna)),
        ],
      ),
    );
  }

  String _formatWaktu(String? dicatatPada, String? waktuMakan) {
    if (dicatatPada == null) return waktuMakan ?? '-';
    try {
      final dt = DateTime.parse(dicatatPada);
      final now = DateTime.now();
      final today = DateFormat('yyyy-MM-dd').format(now);
      final yesterday = DateFormat('yyyy-MM-dd').format(now.subtract(const Duration(days: 1)));
      final logDate = DateFormat('yyyy-MM-dd').format(dt);
      final jam = DateFormat('HH:mm').format(dt);
      String hari;
      if (logDate == today) hari = 'Hari ini';
      else if (logDate == yesterday) hari = 'Kemarin';
      else hari = DateFormat('EEEE', 'id_ID').format(dt);
      return '$hari, $jam • ${waktuMakan ?? ''}';
    } catch (_) { return waktuMakan ?? '-'; }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entriHariIni = _riwayat
        .where((r) => (r['dicatat_pada']?.toString().substring(0, 10) ?? '') == today)
        .length;
    final persenGula = (_totalGula / _batasGulaHarian).clamp(0.0, 1.0);
    final gulaLewat = _totalGula > _batasGulaHarian;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Makan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Color(0xFF2979FF)), onPressed: _loadRiwayat),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : _riwayat.isEmpty
              ? _buildKosong()
              : Column(
                  children: [
                    // Ringkasan kalori & karbo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRingkasan(_totalKalori.toStringAsFixed(0), 'Total Kalori'),
                            _buildPemisah(),
                            _buildRingkasan('${_totalKarbo.toStringAsFixed(0)}g', 'Total Karbo'),
                            _buildPemisah(),
                            _buildRingkasan('$entriHariIni', 'Entri Hari Ini'),
                          ],
                        ),
                      ),
                    ),

                    // Indikator Gula Harian
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🍬', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Text('Total Gula Hari Ini',
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                                const Spacer(),
                                Text(
                                  '${_totalGula.toStringAsFixed(1)}g / ${_batasGulaHarian.toStringAsFixed(0)}g',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: gulaLewat ? const Color(0xFFE53935) : const Color(0xFF43A047),
                                  ),
                                ),
                                if (gulaLewat) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _showPeringatanGula(_totalGula),
                                    child: const Text('⚠️', style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: persenGula,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  gulaLewat ? const Color(0xFFE53935) : const Color(0xFF43A047),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              gulaLewat
                                  ? '⚠ Batas gula harian terlampaui! Kurangi makanan manis.'
                                  : 'Batas gula harian: ${_batasGulaHarian.toStringAsFixed(0)}g (standar Kemenkes untuk diabetes)',
                              style: TextStyle(
                                fontSize: 11,
                                color: gulaLewat ? const Color(0xFFE53935) : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          Text('SEMUA RIWAYAT',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                  color: Colors.grey[500], letterSpacing: 1)),
                        ],
                      ),
                    ),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadRiwayat,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: _riwayat.length,
                          itemBuilder: (context, i) => _buildItemRiwayat(context, _riwayat[i]),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada riwayat makan',
              style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tambahkan makanan pertamamu!',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildRingkasan(String nilai, String label) {
    return Column(
      children: [
        Text(nilai, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildPemisah() =>
      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3));

  Widget _buildItemRiwayat(BuildContext context, Map<String, dynamic> item) {
    final double karbo = (item['total_karbo'] as num?)?.toDouble() ?? 0;
    final double kalori = (item['total_kalori'] as num?)?.toDouble() ?? 0;
    final double gula = (item['total_gula'] as num?)?.toDouble() ?? 0;
    final bool karboTinggi = karbo > 40;
    final bool gulaTinggi = gula > 10;
    final String nama = item['nama_tampil']?.toString() ?? 'Makanan';
    final String emoji = item['emoji']?.toString() ?? '🍽';
    final String waktuStr = _formatWaktu(
      item['dicatat_pada']?.toString(),
      item['waktu_makan']?.toString(),
    );
    final Color warna = _warnaWaktu(item['waktu_makan']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: warna.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(nama,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      ),
                      if (gulaTinggi)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🍬 Gula Tinggi',
                              style: TextStyle(fontSize: 9, color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(waktuStr, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _chipNutrisi('${kalori.toStringAsFixed(0)} kkal', const Color(0xFF2979FF)),
                      _chipNutrisi('${karbo.toStringAsFixed(0)}g karbo',
                          karboTinggi ? const Color(0xFFE65100) : Colors.green),
                      if (gula > 0)
                        _chipNutrisi('${gula.toStringAsFixed(1)}g gula',
                            gulaTinggi ? const Color(0xFFE53935) : Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _konfirmasiHapus(item['id']?.toString() ?? ''),
              child: Icon(Icons.delete_outline, color: Colors.grey[300], size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Color _warnaWaktu(String? waktu) {
    switch (waktu) {
      case 'Sarapan': return const Color(0xFFFF8C00);
      case 'Siang': return const Color(0xFF2979FF);
      case 'Malam': return Colors.indigo;
      case 'Cemilan': return Colors.green;
      default: return const Color(0xFF2979FF);
    }
  }

  Widget _chipNutrisi(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(teks, style: TextStyle(fontSize: 10, color: warna, fontWeight: FontWeight.w600)),
    );
  }

  Future<void> _konfirmasiHapus(String id) async {
    if (id.isEmpty) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Entri'),
        content: const Text('Yakin ingin menghapus catatan makanan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await DatabaseHelper.instance.deleteFoodLog(id);
      _loadRiwayat();
    }
  }
}
