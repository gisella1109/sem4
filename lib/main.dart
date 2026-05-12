import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'pages/login_page.dart';
import 'services/notification_service.dart';
import 'database/database_helper.dart';


void main() async {
  // Wajib sebelum init plugin dan async operations
  WidgetsFlutterBinding.ensureInitialized();

  // 🔥 Load environment variables (.env file)
  await dotenv.load(fileName: "assets/env/.env");
  // 🔥 Inisialisasi database
  if (!kIsWeb) {
    await DatabaseHelper.instance.database;
  }

  // Init push notification service
  await NotificationService().init();

  runApp(const AplikasiKu());
}

class AplikasiKu extends StatelessWidget {
  const AplikasiKu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlucoGuide - Catatan Makan Diabetes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2979FF),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Poppins', // Optional: jika pakai font custom
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: Colors.transparent,
          foregroundColor: Color(0xFF1A1A2E),
        ),
      ),
      home: const LoginPage(),
    );
  }
}