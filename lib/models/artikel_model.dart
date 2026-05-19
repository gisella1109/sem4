class Artikel {
  final String judul;
  final String isi;
  final String gambar;
  final String kategori;
  final String duraBaca;

  Artikel({
    required this.judul,
    required this.isi,
    required this.gambar,
    this.kategori = 'Umum',
    this.duraBaca = '3 menit',
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      judul: json['judul'],
      isi: json['isi'],
      gambar: json['gambar'] ?? '',
      kategori: json['kategori'] ?? 'Umum',
      duraBaca: json['duraBaca'] ?? '3 menit',
    );
  }
}

final List<Artikel> daftarArtikel = [
  Artikel(
    judul: 'Apa itu Diabetes?',
    kategori: 'Dasar',
    duraBaca: '3 menit',
    isi: 'Diabetes adalah kondisi ketika kadar gula dalam darah terlalu tinggi karena tubuh tidak memproduksi atau menggunakan insulin dengan baik.\n\nAda dua tipe utama:\n• Tipe 1: Tubuh tidak memproduksi insulin sama sekali\n• Tipe 2: Tubuh tidak menggunakan insulin secara efektif\n\nGejala umum meliputi sering haus, sering buang air kecil, mudah lelah, dan penglihatan kabur.',
    gambar: 'https://images.unsplash.com/photo-1588776814546-ec7e2c9d4a0f',
  ),
  Artikel(
    judul: 'Memahami Nutrisi untuk Penderita Diabetes',
    kategori: 'Nutrisi',
    duraBaca: '5 menit',
    isi: 'PANDUAN NUTRISI DIABETES\n\nMemahami nutrisi yang tepat sangat penting untuk mengontrol gula darah.\n\n─────────────────────\nKALORI\n─────────────────────\nFungsi: Sumber energi tubuh\nEfek: Kelebihan kalori menyebabkan kenaikan berat badan dan memperburuk resistensi insulin.\nSaran: Sesuaikan asupan kalori dengan kebutuhan harian.\n\n─────────────────────\nKARBOHIDRAT\n─────────────────────\nFungsi: Sumber energi utama\nEfek: Dicerna menjadi glukosa, meningkatkan gula darah secara langsung.\nSaran: Pilih karbohidrat kompleks (nasi merah, ubi, oatmeal) dibanding karbohidrat sederhana.\n\n─────────────────────\nGULA\n─────────────────────\nFungsi: Jenis karbohidrat sederhana\nEfek: Meningkatkan gula darah dengan sangat cepat, perlu dibatasi ketat.\nSaran: Batasi konsumsi gula tambahan maksimal 25g per hari.\n\n─────────────────────\nSERAt\n─────────────────────\nFungsi: Membantu pencernaan\nEfek: Memperlambat penyerapan glukosa, membantu mengontrol gula darah.\nSaran: Konsumsi 25-30g serat per hari dari sayuran, buah, dan biji-bijian.\n\n─────────────────────\nPROTEIN\n─────────────────────\nFungsi: Membangun dan memperbaiki jaringan\nEfek: Tidak langsung mempengaruhi gula darah, membantu rasa kenyang lebih lama.\nSaran: Pilih protein rendah lemak seperti ikan, ayam tanpa kulit, tempe, dan tahu.',
    gambar: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061',
  ),
  Artikel(
    judul: 'Indeks Glikemik: Kunci Kontrol Gula Darah',
    kategori: 'Nutrisi',
    duraBaca: '4 menit',
    isi: 'INDEKS GLIKEMIK (IG)\n\nIndeks Glikemik mengukur seberapa cepat makanan menaikkan kadar gula darah.\n\nKategori IG:\n• IG Rendah (< 55): Aman, naik perlahan → nasi merah, ubi, apel\n• IG Sedang (55-70): Hati-hati → roti gandum, pisang\n• IG Tinggi (> 70): Hindari → nasi putih, roti putih, semangka\n\nTips penting:\n1. Kombinasikan makanan IG tinggi dengan protein/serat untuk memperlambat penyerapan\n2. Cara masak mempengaruhi IG (kentang rebus < kentang goreng)\n3. Makanan dingin cenderung IG lebih rendah dari panas\n\nContoh perbandingan:\n• Nasi putih IG 72 vs Nasi merah IG 55\n• Roti putih IG 70 vs Roti gandum IG 51\n• Semangka IG 72 vs Apel IG 36',
    gambar: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
  ),
  Artikel(
    judul: 'Pentingnya Cek Gula Darah Rutin',
    kategori: 'Monitoring',
    duraBaca: '3 menit',
    isi: 'PANDUAN CEK GULA DARAH\n\nMemantau gula darah secara rutin membantu mencegah komplikasi serius.\n\nTarget gula darah normal:\n• Puasa: 80–130 mg/dL\n• 2 jam setelah makan: < 180 mg/dL\n• HbA1c: < 7%\n\nWaktu terbaik cek gula darah:\n• Pagi (sebelum makan) → mengetahui baseline\n• 2 jam setelah makan → mengukur respons tubuh\n• Sebelum tidur → mencegah hipoglikemia malam\n\nTanda gula darah tinggi (hiperglikemia):\n• Sering haus dan lapar\n• Sering buang air kecil\n• Penglihatan kabur\n• Luka lambat sembuh\n\nTanda gula darah rendah (hipoglikemia):\n• Gemetar dan berkeringat\n• Pusing dan bingung\n• Jantung berdebar',
    gambar: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
  ),
  Artikel(
    judul: 'Tips Pola Makan Sehat untuk Diabetes',
    kategori: 'Gaya Hidup',
    duraBaca: '4 menit',
    isi: 'POLA MAKAN SEHAT DIABETES\n\nMetode Piring Diabetes (porsi ideal per makan):\n• ½ piring → Sayuran non-tepung (bayam, brokoli, wortel)\n• ¼ piring → Protein (ayam, ikan, tahu, tempe)\n• ¼ piring → Karbohidrat (nasi merah, ubi, jagung)\n\nMakanan yang dianjurkan:\n✅ Nasi merah, oatmeal, ubi jalar\n✅ Sayuran hijau, brokoli, bayam\n✅ Ikan, ayam tanpa kulit, tahu, tempe\n✅ Buah rendah gula: apel, jambu biji, belimbing\n✅ Kacang-kacangan\n\nMakanan yang perlu dibatasi:\n❌ Nasi putih berlebihan\n❌ Minuman manis, soda, jus kemasan\n❌ Makanan digoreng\n❌ Kue, roti putih, donat\n❌ Buah tinggi gula berlebihan: durian, mangga\n\nTips makan:\n• Makan 3x sehari + 2 cemilan sehat\n• Jangan lewatkan sarapan\n• Makan perlahan dan kunyah dengan baik',
    gambar: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061',
  ),
  Artikel(
    judul: 'Manfaat Olahraga bagi Penderita Diabetes',
    kategori: 'Gaya Hidup',
    duraBaca: '3 menit',
    isi: 'OLAHRAGA DAN DIABETES\n\nOlahraga membantu tubuh menggunakan insulin lebih efektif dan menurunkan kadar gula darah secara alami.\n\nManfaat olahraga:\n• Menurunkan gula darah langsung\n• Meningkatkan sensitivitas insulin\n• Membantu menjaga berat badan ideal\n• Mengurangi risiko komplikasi jantung\n• Meningkatkan mood dan kualitas tidur\n\nOlahraga yang dianjurkan:\n• Jalan kaki 30 menit sehari\n• Bersepeda santai\n• Renang\n• Yoga atau senam ringan\n• Strength training ringan\n\nPanduan penting:\n⚠️ Cek gula darah sebelum dan sesudah olahraga\n⚠️ Bawa camilan jika gula darah < 100 mg/dL\n⚠️ Minum air putih cukup\n⚠️ Mulai dari intensitas ringan, tingkatkan bertahap',
    gambar: 'https://images.unsplash.com/photo-1554284126-aa88f22d8b74',
  ),
];