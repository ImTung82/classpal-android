import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

import 'core/constants/app_theme.dart';
import 'features/auth/presentation/views/login_register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Load .env
  await dotenv.load(fileName: ".env");

  // 2. Init Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // 3. Kích hoạt Max FPS (Chỉ chạy trên Android Native, bỏ qua Web/iOS)
  if (!kIsWeb && Platform.isAndroid) {
    try {
      await FlutterDisplayMode.setHighRefreshRate();
    } catch (e) {
      debugPrint("Lỗi kích hoạt 120Hz: $e");
    }
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClassPal',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const LoginRegisterScreen(),
    );
  }
}