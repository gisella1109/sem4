import 'package:flutter/material.dart';
import '../models/artikel_model.dart';

class ArtikelEdukasiPage extends StatelessWidget {
  const ArtikelEdukasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edukasi Diabetes"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: daftarArtikel.length,
        itemBuilder: (context, index) {
          final item = daftarArtikel[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailArtikelPage(artikel: item),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ GAMBAR
                  Image.network(
                    item.gambar,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 150,
                        child: Center(
                          child: Icon(Icons.broken_image, size: 40),
                        ),
                      );
                    },
                  ),

                  // ✅ JUDUL
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// ================= DETAIL ARTIKEL =================
class DetailArtikelPage extends StatelessWidget {
  final Artikel artikel;

  const DetailArtikelPage({
    super.key,
    required this.artikel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artikel.judul),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ GAMBAR BESAR
            Image.network(
              artikel.gambar,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),

            // ✅ JUDUL
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                artikel.judul,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // ✅ ISI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                artikel.isi,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}