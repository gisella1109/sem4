// lib/models/jurnal_makanan.dart

import 'food_item.dart';

class JurnalMakanan {
  final String id;

  // Bisa pakai FoodItem (opsional)
  final FoodItem? foodItem;

  // Fallback kalau tidak pakai FoodItem
  final String? namaMakanan;

  final double gram;
  final String waktuMakan; // Sarapan | Siang | Malam | Cemilan

  final double kalori;
  final double karbo;
  final double protein;
  final double lemak;
  final double serat;
  final double gula;

  final int indeksGlikemik;

  final String? fotoPath;
  final DateTime dicatatPada;

  JurnalMakanan({
    required this.id,
    this.foodItem,
    this.namaMakanan,
    required this.gram,
    required this.waktuMakan,
    required this.kalori,
    required this.karbo,
    required this.protein,
    required this.lemak,
    this.serat = 0,
    this.gula = 0,
    this.indeksGlikemik = 50,
    this.fotoPath,
    required this.dicatatPada,
  });

  // ── Nama makanan (otomatis ambil dari FoodItem kalau ada)
  String get displayNama => foodItem?.nama ?? namaMakanan ?? 'Unknown';

  // ── Badge Risiko
  bool get risikoTinggi => indeksGlikemik >= 70;
  bool get risikoSedang => indeksGlikemik >= 55 && indeksGlikemik < 70;

  String? get labelRisiko {
    if (risikoTinggi) return 'Tinggi';
    if (risikoSedang) return 'Sedang';
    return null;
  }

  // ── Dari FoodItem (perhitungan otomatis)
  factory JurnalMakanan.fromFoodItem({
    required String id,
    required FoodItem foodItem,
    required double gram,
    required String waktuMakan,
    String? fotoPath,
    required DateTime dicatatPada,
  }) {
    return JurnalMakanan(
      id: id,
      foodItem: foodItem,
      gram: gram,
      waktuMakan: waktuMakan,
      kalori: foodItem.kaloriUntukGram(gram),
      karbo: foodItem.karboUntukGram(gram),
      protein: foodItem.proteinUntukGram(gram),
      lemak: foodItem.lemakUntukGram(gram),
      serat: foodItem.seratUntukGram(gram),
      gula: foodItem.gulaUntukGram(gram),
      indeksGlikemik: foodItem.indeksGlikemik,
      fotoPath: fotoPath,
      dicatatPada: dicatatPada,
    );
  }

  // ── Untuk SQLite
  Map<String, dynamic> toMap() => {
        'id': id,
        'nama_makanan': displayNama,
        'food_id': foodItem?.id,
        'gram': gram,
        'waktu_makan': waktuMakan,
        'kalori': kalori,
        'karbo': karbo,
        'protein': protein,
        'lemak': lemak,
        'serat': serat,
        'gula': gula,
        'foto_path': fotoPath,
        'dicatat_pada': dicatatPada.toIso8601String(),
        'indeks_glikemik': indeksGlikemik,
      };

  // ── Dari SQLite biasa
  factory JurnalMakanan.fromMap(Map<String, dynamic> m) {
    return JurnalMakanan(
      id: m['id'] as String,
      namaMakanan: m['nama_makanan'] as String?,
      gram: (m['gram'] as num?)?.toDouble() ?? 0,
      waktuMakan: m['waktu_makan'] as String,
      kalori: (m['kalori'] as num).toDouble(),
      karbo: (m['karbo'] as num).toDouble(),
      protein: (m['protein'] as num).toDouble(),
      lemak: (m['lemak'] as num).toDouble(),
      serat: (m['serat'] as num?)?.toDouble() ?? 0,
      gula: (m['gula'] as num?)?.toDouble() ?? 0,
      fotoPath: m['foto_path'] as String?,
      dicatatPada: DateTime.parse(m['dicatat_pada']),
      indeksGlikemik: m['indeks_glikemik'] as int? ?? 50,
    );
  }

  // ── Dari JOIN (food_log + foods)
  factory JurnalMakanan.fromJoinMap(Map<String, dynamic> m) {
    final food = FoodItem(
      id: m['food_id'],
      nama: m['nama'],
      emoji: m['emoji'],
      kaloriPer100g: (m['kalori_100g'] as num).toDouble(),
      karboPer100g: (m['karbo_100g'] as num).toDouble(),
      proteinPer100g: (m['protein_100g'] as num).toDouble(),
      lemakPer100g: (m['lemak_100g'] as num).toDouble(),
      seratPer100g: (m['serat_100g'] as num? ?? 0).toDouble(),
      gulaPer100g: (m['gula_100g'] as num? ?? 0).toDouble(),
      kategori: m['kategori'] ?? 'umum',
      indeksGlikemik: m['indeks_glikemik'] ?? 50,
    );

    return JurnalMakanan.fromFoodItem(
      id: m['log_id'],
      foodItem: food,
      gram: (m['gram'] as num).toDouble(),
      waktuMakan: m['waktu_makan'],
      fotoPath: m['foto_path'],
      dicatatPada: DateTime.parse(m['dicatat_pada']),
    );
  }
}