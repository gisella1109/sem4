class Artikel {
  final int id;
  final String judul;
  final String isi;
  final String ringkasan;
  final String gambar;
  final String kategori;
  final String duraBaca;
  final bool isPublished;
  final int views;
  final String admin;
  final String createdAt;

  Artikel({
    required this.id,
    required this.judul,
    required this.isi,
    required this.ringkasan,
    required this.gambar,
    required this.kategori,
    required this.duraBaca,
    required this.isPublished,
    required this.views,
    required this.admin,
    required this.createdAt,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id:          json['id'] ?? 0,
      judul:       json['judul'] ?? '',
      isi:         json['isi'] ?? '',
      ringkasan:   json['ringkasan'] ?? '',
      gambar:      json['gambar'] ?? '',
      kategori:    json['kategori'] ?? 'Umum',
      duraBaca:    json['dura_baca'] ?? '3 menit',
      isPublished: json['is_published'] ?? false,
      views:       json['views'] ?? 0,
      admin:       json['admin'] ?? 'Admin',
      createdAt:   json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id':           id,
    'judul':        judul,
    'isi':          isi,
    'ringkasan':    ringkasan,
    'gambar':       gambar,
    'kategori':     kategori,
    'dura_baca':    duraBaca,
    'is_published': isPublished,
    'views':        views,
    'admin':        admin,
    'created_at':   createdAt,
  };
}
