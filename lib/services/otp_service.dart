import 'package:http/http.dart' as http;
import 'dart:convert';

class OTPService {
  // Ganti dengan IP Laptop kamu jika pakai Emulator (10.0.2.2) 
  // atau URL domain jika sudah online
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // Fungsi Kirim OTP
  static Future<bool> kirimOTP(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-otp'),
      body: {'email': email},
    );

    return response.statusCode == 200;
  }

  // Fungsi Verifikasi OTP
  static Future<bool> verifikasiOTP(String email, String otp) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-otp'),
      body: {
        'email': email,
        'otp': otp,
      },
    );

    return response.statusCode == 200;
  }
}