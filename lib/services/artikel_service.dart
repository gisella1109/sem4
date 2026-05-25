import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/artikel_model.dart';

class ArtikelService {
  static const String _base = 'http://10.0.2.2:8000/api';

  static Future<String?> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('api_token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _token();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── PASIEN: ambil artikel yang sudah diterbitkan ──────
  static Future<List<Artikel>> fetchArtikel({String? kategori, String? q}) async {
    var url = '$_base/artikels';
    final params = <String>[];
    if (kategori != null && kategori != 'Semua') params.add('kategori=$kategori');
    if (q != null && q.isNotEmpty) params.add('q=$q');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    try {
      final res = await http.get(Uri.parse(url), headers: await _headers());
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final list = data['data'] as List;
        return list.map((e) => Artikel.fromJson(e)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ── PASIEN: detail artikel ────────────────────────────
  static Future<Artikel?> fetchDetail(int id) async {
    try {
      final res = await http.get(Uri.parse('$_base/artikels/$id'), headers: await _headers());
      if (res.statusCode == 200) {
        return Artikel.fromJson(jsonDecode(res.body)['data']);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ── ADMIN: ambil semua artikel (terbit + draf) ────────
  static Future<Map<String, dynamic>> fetchAdminArtikel({String? kategori, String? q}) async {
    var url = '$_base/admin/artikels';
    final params = <String>[];
    if (kategori != null && kategori != 'Semua') params.add('kategori=$kategori');
    if (q != null && q.isNotEmpty) params.add('q=$q');
    if (params.isNotEmpty) url += '?${params.join('&')}';

    try {
      final res = await http.get(Uri.parse(url), headers: await _headers());
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        return {
          'artikels':      (body['data'] as List).map((e) => Artikel.fromJson(e)).toList(),
          'total_terbit':  body['total_terbit'] ?? 0,
          'total_draf':    body['total_draf'] ?? 0,
          'total_views':   body['total_views'] ?? 0,
        };
      }
      return {'artikels': <Artikel>[], 'total_terbit': 0, 'total_draf': 0, 'total_views': 0};
    } catch (_) {
      return {'artikels': <Artikel>[], 'total_terbit': 0, 'total_draf': 0, 'total_views': 0};
    }
  }

  // ── ADMIN: buat artikel baru ──────────────────────────
  static Future<Map<String, dynamic>> buatArtikel({
    required String judul,
    required String isi,
    required String kategori,
    required bool isPublished,
    String? ringkasan,
    String? gambar,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$_base/admin/artikels'),
        headers: await _headers(),
        body: jsonEncode({
          'judul':        judul,
          'isi':          isi,
          'kategori':     kategori,
          'is_published': isPublished,
          'ringkasan':    ringkasan,
          'gambar':       gambar,
        }),
      );
      return {'success': res.statusCode == 201, 'data': jsonDecode(res.body)};
    } catch (e) {
      return {'success': false, 'data': {'message': e.toString()}};
    }
  }

  // ── ADMIN: update artikel ─────────────────────────────
  static Future<Map<String, dynamic>> updateArtikel(int id, {
    String? judul,
    String? isi,
    String? kategori,
    bool? isPublished,
    String? ringkasan,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (judul != null)       body['judul'] = judul;
      if (isi != null)         body['isi'] = isi;
      if (kategori != null)    body['kategori'] = kategori;
      if (isPublished != null) body['is_published'] = isPublished;
      if (ringkasan != null)   body['ringkasan'] = ringkasan;

      final res = await http.put(
        Uri.parse('$_base/admin/artikels/$id'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      return {'success': res.statusCode == 200, 'data': jsonDecode(res.body)};
    } catch (e) {
      return {'success': false, 'data': {'message': e.toString()}};
    }
  }

  // ── ADMIN: hapus artikel ──────────────────────────────
  static Future<bool> hapusArtikel(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$_base/admin/artikels/$id'),
        headers: await _headers(),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}