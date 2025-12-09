import 'package:flutter/material.dart';
// Import file màn hình với tên mới
import 'screens/login_register.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassPal',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4A84F8)),
        useMaterial3: true,
      ),
      // Gọi class LoginRegisterScreen thay vì AuthScreen cũ
      home: const LoginRegisterScreen(),
    );
  }
}