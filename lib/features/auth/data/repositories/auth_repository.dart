import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider cơ bản (giữ nguyên, nhưng khai báo kiểu rõ ràng)
final authRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String name, String email, String password);
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (email.isEmpty) throw Exception("Email không được để trống");
    if (!email.contains("@")) throw Exception("Email không hợp lệ");
    print("MOCK: Login Success $email");
  }

  @override
  Future<void> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (name.isEmpty) throw Exception("Tên không được để trống");
    print("MOCK: Register Success $name");
  }
}