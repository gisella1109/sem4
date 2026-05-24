import 'dart:io';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../database/database_helper.dart';

class FoodRecognitionService {
  // Roboflow YOLO - model makanan Indonesia
  // Daftar di roboflow.com → dapat API key gratis
  static String get _roboflowKey =>
      dotenv.env['ROBOFLOW_API_KEY'] ?? '';
  static String get _modelId =>
      dotenv.env['ROBOFLOW_MODEL_ID'] ?? 'indonesia-food-tjvly';
  static String get _modelVersion =>
      dotenv.env['ROBOFLOW_VERSION'] ?? '1';

  // CalorieNinja sebagai fallback nutrisi
  static String get _calorieKey =>
      dotenv.env['CALORIE_NINJAS_API_KEY'] ?? '';

  /// ============================================================
  /// MAIN METHOD — panggil ini dari food_photo_input_page.dart
  /// Kirim foto → dapat nama makanan + data nutrisi
  /// ============================================================
  Future<Map<String, dynamic>?> analyzeFoodFromPhoto(File imageFile) async {
    // Step 1: Deteksi nama makanan pakai Roboflow YOLO
    final deteksi = await _detectWithRoboflow(imageFile);

    if (deteksi == null || deteksi['nama'] == null) {
      print('Roboflow: tidak terdeteksi');
      return null;
    }

    final namaMakanan = deteksi['nama'] as String;
    final confidence = deteksi['confidence'] as double;
    print('Roboflow deteksi: $namaMakanan (confidence: ${(confidence * 100).toStringAsFixed(1)}%)');

    // Step 2: Cari nutrisi di database lokal dulu (lebih akurat untuk makanan Indonesia)
    final lokalResult = await _searchLocalDatabase(namaMakanan);
    if (lokalResult != null) {
      return {...lokalResult, 'confidence': confidence, 'sumber': 'lokal'};
    }

    // Step 3: Fallback ke CalorieNinja kalau tidak ada di lokal
    final nutrisi = await _getNutrisiCalorieNinja(namaMakanan);
    if (nutrisi != null) {
      return {...nutrisi, 'confidence': confidence, 'sumber': 'calorie_ninja'};
    }

    // Step 4: Return nama saja tanpa nutrisi (user bisa input manual)
    return {
      'nama': namaMakanan,
      'confidence': confidence,
      'sumber': 'deteksi_saja',
      'kalori': 0.0,
      'karbo': 0.0,
      'protein': 0.0,
      'lemak': 0.0,
      'serat': 0.0,
      'gula': 0.0,
    };
  }

  /// ============================================================
  /// Roboflow Inference API — YOLO object detection
  /// Docs: docs.roboflow.com/deploy/hosted-api
  /// ============================================================
  Future<Map<String, dynamic>?> _detectWithRoboflow(File imageFile) async {
    try {
      // Convert foto ke base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Kirim ke Roboflow Hosted Inference API
      final url = Uri.parse(
        'https://detect.roboflow.com/$_modelId/$_modelVersion'
        '?api_key=$_roboflowKey'
        '&confidence=40'   // min confidence 40%
        '&overlap=30',     // max overlap 30%
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: base64Image,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final predictions = data['predictions'] as List?;

        if (predictions != null && predictions.isNotEmpty) {
          // Ambil prediksi dengan confidence tertinggi
          predictions.sort((a, b) =>
              (b['confidence'] as num).compareTo(a['confidence'] as num));

          final best = predictions.first;
          final label = best['class'] as String;
          final confidence = (best['confidence'] as num).toDouble();

          // Map label Roboflow ke nama makanan yang lebih friendly
          final namaMakanan = _mapLabel(label);

          return {
            'nama': namaMakanan,
            'label_asli': label,
            'confidence': confidence,
          };
        }
      } else {
        print('Roboflow error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Roboflow exception: $e');
    }
    return null;
  }

  /// ============================================================
  /// Map label dari Roboflow ke nama makanan yang lebih bersih
  /// ============================================================
  String _mapLabel(String label) {
    // Label dari model Roboflow biasanya sudah dalam bahasa Indonesia
    // tapi kadang perlu dirapikan
    final map = {
      // Makanan Indonesia
      'nasi_goreng': 'Nasi Goreng',
      'nasi goreng': 'Nasi Goreng',
      'mie_goreng': 'Mie Goreng',
      'mie goreng': 'Mie Goreng',
      'ayam_goreng': 'Ayam Goreng',
      'ayam goreng': 'Ayam Goreng',
      'ayam_bakar': 'Ayam Bakar',
      'ikan_goreng': 'Ikan Goreng',
      'ikan_bakar': 'Ikan Bakar',
      'soto_ayam': 'Soto Ayam',
      'bakso': 'Bakso',
      'rendang': 'Rendang',
      'gado_gado': 'Gado-gado',
      'tempe': 'Tempe',
      'tahu': 'Tahu',
      'nasi_putih': 'Nasi Putih',
      'nasi_merah': 'Nasi Merah',
      'bubur': 'Bubur',
      'sate': 'Sate',
      'opor_ayam': 'Opor Ayam',
      'capcay': 'Capcay',
      'kentang_goreng': 'Kentang Goreng',
      'pisang_goreng': 'Pisang Goreng',
      // Makanan internasional
      'pizza': 'Pizza',
      'burger': 'Burger',
      'sushi': 'Sushi',
      'ramen': 'Ramen',
      'fried_chicken': 'Fried Chicken',
      'french_fries': 'French Fries',
      'sandwich': 'Sandwich',
      'salad': 'Salad',
    };

    final lower = label.toLowerCase().replaceAll('-', '_');
    if (map.containsKey(lower)) return map[lower]!;

    // Kalau tidak ada di map, format label jadi Title Case
    return label
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  /// ============================================================
  /// Cari nutrisi di database lokal SQLite
  /// ============================================================
  Future<Map<String, dynamic>?> _searchLocalDatabase(String foodName) async {
    final foods = await DatabaseHelper.instance.searchFoods(foodName);

    if (foods.isNotEmpty) {
      final f = foods.first;
      return {
        'nama'   : f['nama'],
        'kalori' : (f['kalori_100g'] as num).toDouble(),
        'karbo'  : (f['karbo_100g'] as num).toDouble(),
        'protein': (f['protein_100g'] as num).toDouble(),
        'lemak'  : (f['lemak_100g'] as num).toDouble(),
        'serat'  : (f['serat_100g'] as num).toDouble(),
        'gula'   : (f['gula_100g'] as num).toDouble(),
        'ig'     : f['indeks_glikemik'],
        'emoji'  : f['emoji'] ?? '🍽',
        'food_id': f['id'],
      };
    }
    return null;
  }

  /// ============================================================
  /// CalorieNinja API — fallback untuk makanan yang tidak ada di lokal
  /// ============================================================
  Future<Map<String, dynamic>?> _getNutrisiCalorieNinja(String foodName) async {
    if (_calorieKey.isEmpty) return null;
    try {
      final response = await http.get(
        Uri.parse('https://api.calorieninjas.com/v1/nutrition?query=${Uri.encodeComponent(foodName)}'),
        headers: {'X-Api-Key': _calorieKey},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final item = items.first;
          return {
            'nama'   : foodName,
            'kalori' : (item['calories'] ?? 0).toDouble(),
            'karbo'  : (item['carbohydrates_total_g'] ?? 0).toDouble(),
            'protein': (item['protein_g'] ?? 0).toDouble(),
            'lemak'  : (item['fat_total_g'] ?? 0).toDouble(),
            'serat'  : (item['fiber_g'] ?? 0).toDouble(),
            'gula'   : (item['sugar_g'] ?? 0).toDouble(),
          };
        }
      }
    } catch (e) {
      print('CalorieNinja error: $e');
    }
    return null;
  }

  bool isConfigured() => _roboflowKey.isNotEmpty;
}
