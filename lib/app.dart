import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import
import 'features/auth/presentation/views/login_register_screen.dart';

class ClassPalApp extends StatelessWidget {
  const ClassPalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ClassPal',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        // Thiết lập Google Font mặc định cho toàn App
        textTheme: GoogleFonts.robotoTextTheme(), 
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const LoginRegisterScreen(),
    );
  }
}