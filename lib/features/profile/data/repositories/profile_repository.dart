import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _supabase;
  ProfileRepository(this._supabase);

  // Lấy thông tin Profile
  Future<Map<String, dynamic>> getProfile() async {
    final userId = _supabase.auth.currentUser!.id;
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  // 1. Upload Avatar (Supabase Storage v2)
  Future<String> uploadAvatar(File imageFile) async {
    final userId = _supabase.auth.currentUser!.id;
    final fileExt = imageFile.path.split('.').last;

    // Đặt tên file theo timestamp để tránh bị cache trình duyệt
    final fileName =
        '$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    // Upload file
    await _supabase.storage
        .from('avatars')
        .upload(
          fileName,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    // Lấy link Public (v2 trả về String trực tiếp)
    final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);
    return imageUrl;
  }

  // 2. Update thông tin Profile
  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser!.id;

    final updates = {
      'full_name': fullName,
      'phone_number': phone,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _supabase.from('profiles').update(updates).eq('id', userId);
  }
}
