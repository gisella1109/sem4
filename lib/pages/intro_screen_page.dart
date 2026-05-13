import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen>
    with SingleTickerProviderStateMixin {
  int _currentPage = 0;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final List<Map<String, String>> _data = [
    {
      "title": "Pantau Makanan",
      "desc": "Catat makanan harian dengan mudah",
    },
    {
      "title": "Kontrol Gula Darah",
      "desc": "Pantau kadar gula secara rutin",
    },
    {
      "title": "Hidup Lebih Sehat",
      "desc": "Kelola diabetes dengan lebih baik",
    },
  ];

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoFade();
    });
  }

  Future<void> _simpanIntro() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sudahLihatIntro', true);
  }

  Future<void> _startAutoFade() async {
    for (int i = 1; i < _data.length; i++) {
      // Tampilkan halaman selama 2 detik
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;

      // Fade OUT
      await _animController.reverse();
      if (!mounted) return;

      // Ganti konten
      setState(() => _currentPage = i);

      // Fade IN
      await _animController.forward();
      if (!mounted) return;
    }

    // Tahan sebentar di halaman terakhir
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // Fade OUT sebelum pindah ke login
    await _animController.reverse();
    if (!mounted) return;

    await _simpanIntro();

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                      child: Image.asset(
                        'assets/images/logo_foodlog.png',
                        width: 200,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.image,
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    Text(
                      _data[_currentPage]["title"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      _data[_currentPage]["desc"]!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _data.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(4),
                width: _currentPage == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF2979FF)
                      : Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}