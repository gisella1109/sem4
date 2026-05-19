import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan IP laptop kamu saat development
  // Contoh: 'http://192.168.1.5:8000/api'
  // Untuk emulator Android: 'http://10.0.2.2:8000/api'
  // Untuk HP fisik: 'http://192.168.X.X:8000/api' (IP laptop kamu)
  static const String _baseUrl = 'http://10.0.2.2:8000/api';

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
          .timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (_) {
      return null; // offline atau error
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
          .timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> delete(String endpoint) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl$endpoint'), headers: await _headers())
          .timeout(const Duration(seconds: 10));
      return _parseResponse(response);
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic>? _parseResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
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

  // ==================== FOODS ====================
  static Future<List<Map<String, dynamic>>?> searchFoods(String query) async {
    final res = await get('/foods?q=$query');
    if (res == null || res['success'] != true) return null;
    return List<Map<String, dynamic>>.from(res['data']);
  }

  static Future<Map<String, dynamic>?> getFoodById(String id) async {
    final res = await get('/foods/$id');
    if (res == null || res['success'] != true) return null;
    return res['data'];
  }

  // ==================== FOOD LOG ====================
  static Future<Map<String, dynamic>?> getFoodLogs({String? tanggal}) async {
    final query = tanggal != null ? '?tanggal=$tanggal' : '';
    return await get('/food-logs$query');
  }

  static Future<bool> saveFoodLog(Map<String, dynamic> data) async {
    final res = await post('/food-logs', data);
    return res != null && res['success'] == true;
  }

  static Future<bool> deleteFoodLog(String id) async {
    final res = await delete('/food-logs/$id');
    return res != null && res['success'] == true;
  }

  // ==================== GULA DARAH ====================
  static Future<List<Map<String, dynamic>>?> getGulaDarah(
      {String? tanggal}) async {
    final query = tanggal != null ? '?tanggal=$tanggal' : '';
    final res = await get('/gula-darah$query');
    if (res == null || res['success'] != true) return null;
    return List<Map<String, dynamic>>.from(res['data']);
  }

  static Future<Map<String, dynamic>?> saveGulaDarah(
      Map<String, dynamic> data) async {
    return await post('/gula-darah', data);
  }

  static Future<bool> deleteGulaDarah(String id) async {
    final res = await delete('/gula-darah/$id');
    return res != null && res['success'] == true;
  }
}
