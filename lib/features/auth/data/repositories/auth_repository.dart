import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

abstract class AuthRepository {
  Future<AuthResponse> signIn(String email, String password);
  // [CẬP NHẬT] Thêm tham số phone
  Future<AuthResponse> signUp(String email, String password, String name, String phone);
  Future<void> signOut();
  User? get currentUser;
}

class SupabaseAuthRepository implements AuthRepository {
  final GoTrueClient _auth = Supabase.instance.client.auth;

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<AuthResponse> signIn(String email, String password) async {
    return await _auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<AuthResponse> signUp(String email, String password, String name, String phone) async {
    // [CẬP NHẬT] Lưu cả name và phone vào metadata
    return await _auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': name,
        'phone': phone, // Lưu số điện thoại vào đây
      }, 
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}