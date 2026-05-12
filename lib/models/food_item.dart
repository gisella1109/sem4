// lib/models/food_item.dart

class FoodItem {
  final String id;
  final String nama;
  final String emoji;
  final double kaloriPer100g;
  final double karboPer100g;
  final double proteinPer100g;
  final double lemakPer100g;
  final double seratPer100g;
  final double gulaPer100g;
  final String kategori;
  // Indeks glikemik — penting untuk pasien diabetes
  final int indeksGlikemik;

  const FoodItem({
    required this.id,
    required this.nama,
    required this.emoji,
    required this.kaloriPer100g,
    required this.karboPer100g,
    required this.proteinPer100g,
    required this.lemakPer100g,
    this.seratPer100g = 0,
    this.gulaPer100g = 0,
    this.kategori = 'umum',
    this.indeksGlikemik = 50,
  });

  // ── Hitung nutrisi untuk sejumlah gram ──────────
  double kaloriUntukGram(double g)  => (kaloriPer100g  * g) / 100;
  double karboUntukGram(double g)   => (karboPer100g   * g) / 100;
  double proteinUntukGram(double g) => (proteinPer100g * g) / 100;
  double lemakUntukGram(double g)   => (lemakPer100g   * g) / 100;
  double seratUntukGram(double g)   => (seratPer100g   * g) / 100;
  double gulaUntukGram(double g)    => (gulaPer100g    * g) / 100;

  // ── Klasifikasi risiko gula darah ───────────────
  // Berdasarkan indeks glikemik (IG)
  // IG < 55  = Rendah (aman diabetes)
  // IG 55-69 = Sedang (perlu perhatian)
  // IG >= 70 = Tinggi (hati-hati)
  String get levelRisikoGula {
    if (indeksGlikemik < 55) return 'rendah';
    if (indeksGlikemik < 70) return 'sedang';
    return 'tinggi';
  }

  String get pesanRisiko {
    switch (levelRisikoGula) {
      case 'rendah':
        return 'Indeks glikemik rendah (IG $indeksGlikemik). Aman dikonsumsi penderita diabetes.';
      case 'sedang':
        return 'Indeks glikemik sedang (IG $indeksGlikemik). Batasi porsi dan kombinasikan dengan protein/serat.';
      case 'tinggi':
        return 'Indeks glikemik tinggi (IG $indeksGlikemik). Hati-hati, dapat meningkatkan gula darah dengan cepat.';
      default:
        return '';
    }
  }

  // ── fromMap / toMap untuk SQLite ────────────────
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id:              map['id']              as String,
      nama:            map['nama']            as String,
      emoji:           map['emoji']           as String,
      kaloriPer100g:   (map['kalori_100g']    as num).toDouble(),
      karboPer100g:    (map['karbo_100g']     as num).toDouble(),
      proteinPer100g:  (map['protein_100g']   as num).toDouble(),
      lemakPer100g:    (map['lemak_100g']     as num).toDouble(),
      seratPer100g:    (map['serat_100g']     as num? ?? 0).toDouble(),
      gulaPer100g:     (map['gula_100g']      as num? ?? 0).toDouble(),
      kategori:        map['kategori']        as String? ?? 'umum',
      indeksGlikemik:  map['indeks_glikemik'] as int? ?? 50,
    );
  }

  Map<String, dynamic> toMap() => {
    'id':              id,
    'nama':            nama,
    'emoji':           emoji,
    'kalori_100g':     kaloriPer100g,
    'karbo_100g':      karboPer100g,
    'protein_100g':    proteinPer100g,
    'lemak_100g':      lemakPer100g,
    'serat_100g':      seratPer100g,
    'gula_100g':       gulaPer100g,
    'kategori':        kategori,
    'indeks_glikemik': indeksGlikemik,
  };
}