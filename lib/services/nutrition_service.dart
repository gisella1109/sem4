import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class NutritionService {
  static Future<Map<String, dynamic>?> getNutrition(
    String query,
  ) async {
    try {
      final apiKey =
          dotenv.env['CALORIE_NINJAS_API_KEY'];

      final response = await http.get(
        Uri.parse(
          'https://api.calorieninjas.com/v1/nutrition?query=$query',
        ),
        headers: {
          'X-Api-Key': apiKey ?? '',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['items'] != null &&
            data['items'].isNotEmpty) {
          return data['items'][0];
        }
      }

      return null;
    } catch (e) {
      print('Nutrition Error: $e');
      return null;
    }
  }
}