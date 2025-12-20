import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Lấy thông tin Profile
  Future<ProfileModel> getProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();

    return ProfileModel.fromJson(data);
  }

  // 2. Cập nhật thông tin (DB + Auth Metadata)
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    // Update DB
    await _supabase
        .from('profiles')
        .update({
          'full_name': fullName,
          'phone_number': phone,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', user.id);

    // Update Auth Metadata (để hiển thị nhanh ở Drawer)
    await _supabase.auth.updateUser(
      UserAttributes(data: {'full_name': fullName, 'phone': phone}),
    );
  }

  // 3. Đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());
