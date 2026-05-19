import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'pages/login_page.dart';
import 'pages/intro_screen_page.dart';
import 'services/notification_service.dart';
import 'database/database_helper.dart';

import 'package:flutter/rendering.dart';  

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load ENV
  await dotenv.load(fileName: ".env");

  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;

  // Init database hanya untuk mobile/desktop
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  // Init notification
  await NotificationService().init();

  // Cek intro screen
  final prefs = await SharedPreferences.getInstance();
  final sudahLihatIntro =
      prefs.getBool('sudahLihatIntro') ?? false;

  runApp(
    AplikasiKu(
      tampilkanIntro: !sudahLihatIntro,
    ),
  );
}

class AplikasiKu extends StatelessWidget {
  final bool tampilkanIntro;

  const AplikasiKu({
    super.key,
    required this.tampilkanIntro,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoGuide - Catatan Makan Diabetes',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2979FF),
          brightness: Brightness.light,
        ),

        fontFamily: 'Poppins',

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A1A2E),
        ),
      ),

      // Halaman awal
      home: tampilkanIntro
          ? const IntroScreen()
          : const LoginPage(),
    );
  }
}