import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import màn hình đích (Auth & Class)
import '../../../auth/presentation/views/login_register_screen.dart';
import '../../../classes/presentation/views/classroom_page_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    final results = await Future.wait([
      // Tác vụ 1: Đợi tối thiểu 2 giây
      Future.delayed(const Duration(seconds: 2)),

      // Tác vụ 2: Lấy session
      Future<Session?>.microtask(() async {
        return Supabase.instance.client.auth.currentSession;
      }),
    ]);

    final session = results[1] as Session?;

    if (!mounted) return;

    if (session != null) {
      // Đã đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ClassroomPageScreen()),
      );
    } else {
      // Chưa đăng nhập
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginRegisterScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = const [
      Color(0xFF4A84F8),
      Color(0xFF9D53F7),
    ];

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // --- LOGO SECTION ---
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                LucideIcons.users,
                size: 60,
                color: gradientColors[0],
              ),
            ),
            const SizedBox(height: 24),

            // --- APP NAME ---
            Text(
              "ClassPal",
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              "Lớp trưởng 4.0",
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 60),

            // --- LOADING ---
            const SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
