import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/artikel_model.dart';
import '../models/food_item.dart';
import '../models/food_journal.dart';
import '../models/glucose_entry.dart';

class ApiService {
  // ─── IP LAPTOP (Wi-Fi) ───────────────────────────────────
static const String _baseUrl = 'http://192.168.1.10:8000/api';
  // Kalau pakai emulator ganti ke: 'http://10.0.2.2:8000/api'
  // ─────────────────────────────────────────────────────────

  static const Duration _timeout = Duration(seconds: 10);
  static String? _token;

  // ==================== TOKEN ====================
  static Future<void> simpanToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_token', token);
  }

  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('api_token');
    return _token;
  }

  static Future<void> hapusToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('api_token');
  }

  // ==================== CEK KONEKSI ====================
  static Future<bool> isOnline() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ==================== HEADERS ====================
  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== HTTP METHODS ====================
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl$endpoint'), headers: await _headers())
          .timeout(_timeout);
      return _parseResponse(response);
    } on TimeoutException {
      throw Exception('Koneksi timeout. Pastikan server berjalan.');
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseResponse(response);
    } on TimeoutException {
      throw Exception('Koneksi timeout. Pastikan server berjalan.');
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  static Future<Map<String, dynamic>?> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: await _headers(),
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _parseResponse(response);
    } on TimeoutException {
      throw Exception('Koneksi timeout.');
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  static Future<Map<String, dynamic>?> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: await _headers())
          .timeout(_timeout);
      return _parseResponse(response);
    } on TimeoutException {
      throw Exception('Koneksi timeout.');
    } catch (e) {
      throw Exception('Tidak dapat terhubung ke server: $e');
    }
  }

  static Map<String, dynamic>? _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic>) return data;
      if (data is List) return {'success': true, 'data': data};
      return null;
    } catch (_) {
      return null;
    }
  }

  // ==================== AUTH ====================
  static Future<Map<String, dynamic>?> login(
      String email, String password) async {
    final res = await post('/login', {'email': email, 'password': password});
    if (res != null && res['success'] == true) {
      await simpanToken(res['token']);
    }
    return res;
  }

  static Future<Map<String, dynamic>?> register(
      String nama, String email, String password) async {
    final res = await post('/register', {
      'nama': nama,
      'email': email,
      'password': password,
    });
    if (res != null && res['success'] == true) {
      await simpanToken(res['token']);
    }
    return res;
  }

  static Future<void> logout() async {
    await post('/logout', {});
    await hapusToken();
  }

  // ==================== ARTIKEL (USER — publik) ====================
  // Pakai model: Artikel dari artikel_model.dart
  // Field: id, judul, isi, ringkasan, gambar, kategori, duraBaca,
  //        isPublished, views, admin, createdAt

  static Future<List<Artikel>> getArtikel() async {
    final res = await get('/artikels');
    if (res == null) return [];
    final List data = res['data'] ?? [];
    return data.map((e) => Artikel.fromJson(e)).toList();
  }

  // ==================== ARTIKEL (ADMIN) ====================
  static Future<List<Artikel>> getArtikelAdmin() async {
    final res = await get('/admin/artikels');
    if (res == null) return [];
    final List data = res['data'] ?? [];
    return data.map((e) => Artikel.fromJson(e)).toList();
  }

  static Future<Artikel?> createArtikel({
    required String judul,
    required String isi,
    required String kategori,
    bool isPublished = false,
    String? gambar,
  }) async {
    final res = await post('/admin/artikels', {
      'judul':        judul,
      'isi':          isi,
      'kategori':     kategori,
      'is_published': isPublished,
      if (gambar != null) 'gambar': gambar,
    });
    if (res == null || res['success'] != true) return null;
    return Artikel.fromJson(res['data']);
  }

  static Future<bool> deleteArtikel(int id) async {
    final res = await delete('/admin/artikels/$id');
    return res != null && res['success'] == true;
  }

  // ==================== FOODS ====================
  // Pakai model: FoodItem dari food_item.dart
  // Field: id (String), nama, emoji, kaloriPer100g, karboPer100g,
  //        proteinPer100g, lemakPer100g, seratPer100g, gulaPer100g,
  //        kategori, indeksGlikemik

  static Future<List<FoodItem>> searchFoods(String query) async {
    final res = await get('/foods?q=$query');
    if (res == null || res['success'] != true) return [];
    final List data = res['data'] ?? [];
    return data.map((e) => FoodItem.fromMap({
      'id':              e['id']?.toString() ?? '',
      'nama':            e['nama'] ?? e['name'] ?? '',
      'emoji':           e['emoji'] ?? '🍽️',
      'kalori_100g':     e['kalori_per_100g'] ?? e['kalori_100g'] ?? 0,
      'karbo_100g':      e['karbo_per_100g'] ?? e['karbo_100g'] ?? 0,
      'protein_100g':    e['protein_per_100g'] ?? e['protein_100g'] ?? 0,
      'lemak_100g':      e['lemak_per_100g'] ?? e['lemak_100g'] ?? 0,
      'serat_100g':      e['serat_per_100g'] ?? e['serat_100g'] ?? 0,
      'gula_100g':       e['gula_per_100g'] ?? e['gula_100g'] ?? 0,
      'kategori':        e['kategori'] ?? 'umum',
      'indeks_glikemik': e['indeks_glikemik'] ?? e['glycemic_index'] ?? 50,
    })).toList();
  }

  static Future<FoodItem?> getFoodById(String id) async {
    final res = await get('/foods/$id');
    if (res == null || res['success'] != true) return null;
    final e = res['data'];
    return FoodItem.fromMap({
      'id':              e['id']?.toString() ?? '',
      'nama':            e['nama'] ?? e['name'] ?? '',
      'emoji':           e['emoji'] ?? '🍽️',
      'kalori_100g':     e['kalori_per_100g'] ?? e['kalori_100g'] ?? 0,
      'karbo_100g':      e['karbo_per_100g'] ?? e['karbo_100g'] ?? 0,
      'protein_100g':    e['protein_per_100g'] ?? e['protein_100g'] ?? 0,
      'lemak_100g':      e['lemak_per_100g'] ?? e['lemak_100g'] ?? 0,
      'serat_100g':      e['serat_per_100g'] ?? e['serat_100g'] ?? 0,
      'gula_100g':       e['gula_per_100g'] ?? e['gula_100g'] ?? 0,
      'kategori':        e['kategori'] ?? 'umum',
      'indeks_glikemik': e['indeks_glikemik'] ?? 50,
    });
  }

  // ==================== FOOD LOG ====================
  // Pakai model: JurnalMakanan dari food_journal.dart

  static Future<List<JurnalMakanan>> getFoodLogs({String? tanggal}) async {
    final query = tanggal != null ? '?tanggal=$tanggal' : '';
    final res = await get('/food-logs$query');
    if (res == null || res['success'] != true) return [];
    final List data = res['data'] ?? [];
    return data.map((e) => JurnalMakanan.fromMap({
      'id':              e['id']?.toString() ?? '',
      'nama_makanan':    e['food_name'] ?? e['nama_makanan'] ?? '',
      'food_id':         e['food_id']?.toString(),
      'gram':            e['portion'] ?? e['gram'] ?? 0,
      'waktu_makan':     e['meal_time'] ?? e['waktu_makan'] ?? '',
      'kalori':          e['calories'] ?? e['kalori'] ?? 0,
      'karbo':           e['carbs'] ?? e['karbo'] ?? 0,
      'protein':         e['protein'] ?? 0,
      'lemak':           e['fat'] ?? e['lemak'] ?? 0,
      'serat':           e['fiber'] ?? e['serat'] ?? 0,
      'gula':            e['sugar'] ?? e['gula'] ?? 0,
      'foto_path':       e['photo_path'] ?? e['foto_path'],
      'dicatat_pada':    e['created_at'] ?? e['dicatat_pada'] ?? DateTime.now().toIso8601String(),
      'indeks_glikemik': e['glycemic_index'] ?? e['indeks_glikemik'] ?? 50,
    })).toList();
  }

  static Future<bool> saveFoodLog(JurnalMakanan jurnal) async {
    final res = await post('/food-logs', {
      'food_name':    jurnal.displayNama,
      'meal_time':    jurnal.waktuMakan,
      'calories':     jurnal.kalori.round(),
      'carbs':        jurnal.karbo.round(),
      'protein':      jurnal.protein,
      'fat':          jurnal.lemak,
      'portion':      jurnal.gram,
      'portion_unit': 'gram',
      'input_method': jurnal.fotoPath != null ? 'photo' : 'manual',
      if (jurnal.fotoPath != null) 'photo_path': jurnal.fotoPath,
    });
    return res != null && res['success'] == true;
  }

  static Future<bool> deleteFoodLog(String id) async {
    final res = await delete('/food-logs/$id');
    return res != null && res['success'] == true;
  }

  // ==================== GULA DARAH ====================
  // Pakai model: GlucoseEntry dari glucose_entry.dart
  // Field: nilai (double), waktu (DateTime), konteksMakan, catatan

  static Future<List<GlucoseEntry>> getGulaDarah({String? tanggal}) async {
    final query = tanggal != null ? '?tanggal=$tanggal' : '';
    final res = await get('/gula-darah$query');
    if (res == null || res['success'] != true) return [];
    final List data = res['data'] ?? [];
    return data.map((e) => GlucoseEntry(
      nilai:        (e['kadar'] ?? e['nilai'] ?? 0).toDouble(),
      waktu:        DateTime.tryParse(e['created_at'] ?? '') ?? DateTime.now(),
      konteksMakan: e['waktu'] ?? e['konteks_makan'] ?? '',
      catatan:      e['catatan'] ?? '',
    )).toList();
  }

  static Future<bool> saveGulaDarah(GlucoseEntry entry) async {
    final res = await post('/gula-darah', {
      'kadar':         entry.nilai.round(),
      'waktu':         entry.konteksMakan,
      'catatan':       entry.catatan,
      'tanggal':       entry.waktu.toIso8601String().split('T')[0],
    });
    return res != null && res['success'] == true;
  }

  static Future<bool> deleteGulaDarah(String id) async {
    final res = await delete('/gula-darah/$id');
    return res != null && res['success'] == true;
  }
}