import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

abstract class AuthRepository {
  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String phone,
  );
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Future<void> updatePassword(String newPassword);
  Future<User?> refreshSession();
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
  Future<AuthResponse> signUp(
    String email,
    String password,
    String name,
    String phone,
  ) async {
    return await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name, 'phone': phone},
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.classpal.app://reset-callback',
    );
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<User?> refreshSession() async {
    final response = await _auth.refreshSession();
    return response.user;
  }
}
