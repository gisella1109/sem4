import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/artikel_model.dart';

class ArtikelService {
  static Future<List<Artikel>> fetchArtikel() async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/artikel'),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => Artikel.fromJson(e)).toList();
    } else {
      throw Exception('Gagal load artikel');
    }
  }
}