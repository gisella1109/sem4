// lib/services/food_recognition_service.dart

import 'dart:io';
import 'dart:convert';
import 'package:glucoguide/database/database_helper.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FoodRecognitionService {
  // 🔥 Ganti dengan API Key Anda dari Google Cloud Vision
  static const String _visionApiKey = 'YOUR_GOOGLE_VISION_API_KEY';
  static const String _visionUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  // 🔥 Ganti dengan API Key dari CalorieNinjas
  static const String _calorieApiKey = 'YOUR_CALORIE_NINJAS_API_KEY';
  static const String _calorieUrl = 'https://api.calorieninjas.com/v1/nutrition';
  
  /// Step 1: Deteksi makanan dari foto menggunakan Google Cloud Vision
  Future<String?> detectFoodFromImage(File imageFile) async {
    try {
      // Convert gambar ke base64
      List<int> imageBytes = await imageFile.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Panggil Google Cloud Vision API
      final response = await http.post(
        Uri.parse('$_visionUrl?key=$_visionApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requests': [{
            'image': {'content': base64Image},
            'features': [
              {'type': 'LABEL_DETECTION', 'maxResults': 10},
              {'type': 'OBJECT_LOCALIZATION', 'maxResults': 5}
            ],
            'imageContext': {
              'languageHints': ['id', 'en']
            }
          }]
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final labels = data['responses'][0]['labelAnnotations'] as List?;
        
        if (labels != null && labels.isNotEmpty) {
          // Cari label yang berhubungan dengan makanan
          for (var label in labels) {
            String description = label['description'] as String? ?? '';
            double score = (label['score'] as num?)?.toDouble() ?? 0;
            
            if (_isFoodRelated(description) && score > 0.6) {
              // Mapping label Indonesia ke nama makanan yang lebih akurat
              String foodName = _mapToIndonesianFood(description);
              print('Detected: $description (Score: $score) -> Mapped to: $foodName');
              return foodName;
            }
          }
        }
      } else {
        print('Vision API Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error detecting food: $e');
    }
    
    return null;
  }
  
  /// Cek apakah label berhubungan dengan makanan
  bool _isFoodRelated(String label) {
    List<String> foodKeywords = [
      // English
      'food', 'dish', 'meal', 'cuisine', 'breakfast', 'lunch', 'dinner',
      'rice', 'noodle', 'soup', 'chicken', 'meat', 'fish', 'egg', 'tofu',
      'vegetable', 'fruit', 'salad', 'cake', 'bread', 'pastry', 'snack',
      // Indonesian
      'makanan', 'nasi', 'mie', 'ayam', 'sapi', 'ikan', 'telur', 'tahu', 'tempe',
      'sayur', 'buah', 'goreng', 'bakar', 'rebus', 'soto', 'bakso', 'rendang',
      'gado', 'pecel', 'opor', 'capcay', 'bubur', 'ketoprak', 'siomay'
    ];
    
    return foodKeywords.any((keyword) => 
      label.toLowerCase().contains(keyword.toLowerCase()));
  }
  
  /// Mapping label dari Vision API ke nama makanan Indonesia
  String _mapToIndonesianFood(String label) {
    final Map<String, String> mapping = {
      // Nasi
      'fried rice': 'Nasi Goreng',
      'rice': 'Nasi Putih',
      'steamed rice': 'Nasi Putih',
      'red rice': 'Nasi Merah',
      
      // Ayam
      'fried chicken': 'Ayam Goreng',
      'grilled chicken': 'Ayam Bakar',
      'chicken': 'Ayam',
      'chicken soup': 'Soto Ayam',
      
      // Mie
      'noodle': 'Mie',
      'fried noodle': 'Mie Goreng',
      'noodle soup': 'Mie Kuah',
      
      // Lainnya
      'tofu': 'Tahu',
      'tempeh': 'Tempe',
      'egg': 'Telur',
      'beef': 'Daging Sapi',
      'fish': 'Ikan',
      'vegetable': 'Sayur',
      'fruit': 'Buah',
    };
    
    // Coba cari mapping
    for (var entry in mapping.entries) {
      if (label.toLowerCase().contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Jika tidak ada mapping, format label
    return label.split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1).toLowerCase()
    ).join(' ');
  }
  
  /// Step 2: Dapatkan nutrisi dari nama makanan menggunakan CalorieNinjas
  Future<Map<String, dynamic>?> getNutritionFromName(String foodName) async {
    try {
      final response = await http.get(
        Uri.parse('$_calorieUrl?query=${Uri.encodeComponent(foodName)}'),
        headers: {'X-Api-Key': _calorieApiKey},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final items = data['items'] as List?;
        
        if (items != null && items.isNotEmpty) {
          final item = items[0];
          return {
            'nama': foodName,
            'kalori': (item['calories'] ?? 0).toDouble(),
            'karbo': (item['carbohydrates_total_g'] ?? 0).toDouble(),
            'protein': (item['protein_g'] ?? 0).toDouble(),
            'lemak': (item['fat_total_g'] ?? 0).toDouble(),
            'serat': (item['fiber_g'] ?? 0).toDouble(),
            'gula': (item['sugar_g'] ?? 0).toDouble(),
          };
        }
      }
    } catch (e) {
      print('Error getting nutrition: $e');
    }
    
    return null;
  }
  
  /// 🔥 MAIN METHOD: Deteksi makanan dari foto + dapatkan nutrisi
  Future<Map<String, dynamic>?> analyzeFoodFromPhoto(File imageFile) async {
    // Step 1: Deteksi nama makanan dari foto
    String? foodName = await detectFoodFromImage(imageFile);
    
    if (foodName == null) {
      print('Tidak dapat mendeteksi makanan dari foto');
      return null;
    }
    
    // Step 2: Dapatkan nutrisi dari nama makanan
    Map<String, dynamic>? nutrition = await getNutritionFromName(foodName);
    
    if (nutrition != null) {
      return nutrition;
    }
    
    // Jika CalorieNinjas gagal, coba database lokal
    return await _searchLocalDatabase(foodName);
  }
  
  /// Fallback: Cari di database lokal
  Future<Map<String, dynamic>?> _searchLocalDatabase(String foodName) async {
    final dbHelper = DatabaseHelper.instance;
    final foods = await dbHelper.searchFoods(foodName);
    
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
  
  bool isConfigured() {
    return _visionApiKey != 'YOUR_GOOGLE_VISION_API_KEY' && 
           _calorieApiKey != 'YOUR_CALORIE_NINJAS_API_KEY';
  }
}