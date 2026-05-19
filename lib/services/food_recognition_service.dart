import 'dart:io';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:glucoguide/database/database_helper.dart';
import 'package:http/http.dart' as http;

class FoodRecognitionService {

  // API KEY dari .env
  static String get _visionApiKey =>
      dotenv.env['GOOGLE_VISION_API_KEY'] ?? '';

  static String get _calorieApiKey =>
      dotenv.env['CALORIE_NINJAS_API_KEY'] ?? '';

  static const String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate';

  static const String _calorieUrl =
      'https://api.calorieninjas.com/v1/nutrition';

  /// ==============================
  /// DETEKSI MAKANAN DARI FOTO
  /// ==============================
  Future<String?> detectFoodFromImage(File imageFile) async {
    try {
      // convert image -> base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      // request ke Google Vision API
      final response = await http.post(
        Uri.parse('$_visionUrl?key=$_visionApiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requests': [
            {
              'image': {
                'content': base64Image,
              },
              'features': [
                {
                  'type': 'LABEL_DETECTION',
                  'maxResults': 15,
                }
              ]
            }
          ]
        }),
      );

      // sukses
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final labels =
            data['responses'][0]['labelAnnotations'];

        print('===== HASIL DETEKSI =====');
            print(response.body);

        for (var label in labels) {
          print(
            '${label['description']} | score: ${label['score']}',
          );
        }

        // =========================
        // PRIORITAS DETEKSI MAKANAN
        // =========================

        for (var label in labels) {
          final text =
              label['description']
                  .toString()
                  .toLowerCase();

          // NASI
          if (text.contains('fried rice')) {
            return 'Nasi Goreng';
          }

          if (text.contains('rice')) {
            return 'Nasi Putih';
          }

          // MIE
          if (text.contains('noodle')) {
            return 'Mie Goreng';
          }

          // AYAM
          if (text.contains('fried chicken')) {
            return 'Ayam Goreng';
          }

          if (text.contains('grilled chicken')) {
            return 'Ayam Bakar';
          }

          if (text.contains('chicken')) {
            return 'Ayam';
          }

          // LAINNYA
          if (text.contains('burger')) {
            return 'Burger';
          }

          if (text.contains('pizza')) {
            return 'Pizza';
          }

          if (text.contains('salad')) {
            return 'Salad';
          }

          if (text.contains('soup')) {
            return 'Sup';
          }

          if (text.contains('egg')) {
            return 'Telur';
          }

          if (text.contains('fish')) {
            return 'Ikan';
          }

          if (text.contains('meat')) {
            return 'Daging';
          }

          if (text.contains('vegetable')) {
            return 'Sayur';
          }
        }

        // fallback label pertama
        if (labels.isNotEmpty) {
          return labels[0]['description'];
        }
      } else {
        print('Vision API Error: ${response.body}');
      }
    } catch (e) {
      print('ERROR DETECT FOOD: $e');
    }

    return null;
  }

  /// ==============================
  /// AMBIL NUTRISI DARI CALORIE API
  /// ==============================
  Future<Map<String, dynamic>?> getNutritionFromName(
    String foodName,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_calorieUrl?query=${Uri.encodeComponent(foodName)}',
        ),
        headers: {
          'X-Api-Key': _calorieApiKey,
        },
      );

      print('NUTRITION STATUS: ${response.statusCode}');
      print('NUTRITION BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final items = data['items'];

        if (items != null && items.isNotEmpty) {
          final item = items[0];

          return {
            'nama': foodName,
            'kalori':
                (item['calories'] ?? 0).toDouble(),

            'karbo':
                (item['carbohydrates_total_g'] ?? 0)
                    .toDouble(),

            'protein':
                (item['protein_g'] ?? 0).toDouble(),

            'lemak':
                (item['fat_total_g'] ?? 0).toDouble(),

            'serat':
                (item['fiber_g'] ?? 0).toDouble(),

            'gula':
                (item['sugar_g'] ?? 0).toDouble(),
          };
        }
      }
    } catch (e) {
      print('ERROR NUTRITION: $e');
    }

    return null;
  }

  /// ==============================
  /// MAIN ANALYZE
  /// ==============================
  Future<Map<String, dynamic>?> analyzeFoodFromPhoto(
    File imageFile,
  ) async {

    print('===== MULAI ANALISIS FOTO =====');

    // step 1 deteksi makanan
    String? foodName =
        await detectFoodFromImage(imageFile);

    print('HASIL DETEKSI: $foodName');

    if (foodName == null) {
      return null;
    }

    // step 2 ambil nutrisi
    final nutrition =
        await getNutritionFromName(foodName);

    // jika berhasil dari API
    if (nutrition != null) {
      print('BERHASIL DAPAT NUTRISI DARI API');
      return nutrition;
    }

    // fallback database lokal
    print('FALLBACK KE DATABASE LOKAL');

    return await _searchLocalDatabase(foodName);
  }

  /// ==============================
  /// FALLBACK DATABASE
  /// ==============================
  Future<Map<String, dynamic>?> _searchLocalDatabase(
    String foodName,
  ) async {

    final dbHelper = DatabaseHelper.instance;

    final foods =
        await dbHelper.searchFoods(foodName);

    if (foods.isNotEmpty) {
      return {
        'nama': foods[0]['nama'],
        'kalori': foods[0]['kalori_100g'],
        'karbo': foods[0]['karbo_100g'],
        'protein': foods[0]['protein_100g'],
        'lemak': foods[0]['lemak_100g'],
        'serat': foods[0]['serat_100g'],
        'gula': foods[0]['gula_100g'],
      };
    }

    return null;
  }

  /// ==============================
  /// CHECK API
  /// ==============================
  bool isConfigured() {
    return _visionApiKey.isNotEmpty &&
        _calorieApiKey.isNotEmpty;
  }
}