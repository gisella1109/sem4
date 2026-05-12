class Artikel {
  final String judul;
  final String isi;
  final String gambar;

  Artikel({
    required this.judul,
    required this.isi,
    required this.gambar,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      judul: json['judul'],
      isi: json['isi'],
      gambar: json['gambar'] ?? '',
    );
  }
}

final List<Artikel> daftarArtikel = [
  Artikel(
    judul: 'Apa itu Diabetes?',
    isi: 'Diabetes adalah kondisi ketika kadar gula dalam darah terlalu tinggi karena tubuh tidak memproduksi insulin dengan baik.',
    gambar: 'https://images.unsplash.com/photo-1588776814546-ec7e2c9d4a0f',
  ),
  Artikel(
    judul: 'Pentingnya Cek Gula Darah',
    isi: 'Memantau gula darah secara rutin membantu mencegah komplikasi serius seperti penyakit jantung dan ginjal.',
    gambar: 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d',
  ),
  Artikel(
    judul: 'Tips Pola Makan Sehat',
    isi: 'Konsumsi makanan tinggi serat, hindari gula berlebih, dan atur porsi makan secara seimbang.',
    gambar: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061',
  ),
  Artikel(
    judul: 'Manfaat Olahraga',
    isi: 'Olahraga membantu tubuh menggunakan insulin lebih efektif dan menurunkan kadar gula darah.',
    gambar: 'https://images.unsplash.com/photo-1554284126-aa88f22d8b74',
  ),
];