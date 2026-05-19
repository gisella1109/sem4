import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VisionService {
  static Future<String?> detectFood(File imageFile) async {
    try {
      final apiKey = dotenv.env['GOOGLE_VISION_API_KEY'];

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse(
          'https://vision.googleapis.com/v1/images:annotate?key=$apiKey',
        ),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          "requests": [
            {
              "image": {
                "content": base64Image,
              },
              "features": [
                {
                  "type": "LABEL_DETECTION",
                  "maxResults": 10
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final labels =
            data['responses'][0]['labelAnnotations'];

        for (var label in labels) {
          final text =
              label['description'].toString().toLowerCase();

          if (text.contains('food') ||
              text.contains('rice') ||
              text.contains('noodle') ||
              text.contains('fried rice') ||
              text.contains('chicken') ||
              text.contains('meal')) {
            return label['description'];
          }
        }

        return labels[0]['description'];
      }

      return null;
    } catch (e) {
      print('Vision Error: $e');
      return null;
    }
  }
}