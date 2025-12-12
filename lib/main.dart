import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // BẮT BUỘC: Bọc toàn bộ app bằng ProviderScope để Riverpod hoạt động
    const ProviderScope(
      child: ClassPalApp(),
    ),
  );
}