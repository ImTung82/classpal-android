import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';

final currentProfileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfile();
});

// Khai báo Provider kiểu mới (Riverpod 3.0)
final profileViewModelProvider = AsyncNotifierProvider<ProfileViewModel, void>(
  ProfileViewModel.new,
);

class ProfileViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    return;
  }

  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  // Hàm update profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      String? avatarUrl;

      // 1. Upload ảnh nếu có
      if (imageFile != null) {
        avatarUrl = await _repo.uploadAvatar(imageFile);
      }

      // 2. Update thông tin
      await _repo.updateProfile(
        fullName: name,
        phone: phone,
        avatarUrl: avatarUrl,
      );
      
      // 3. Làm mới dữ liệu để Drawer cập nhật ngay lập tức
      ref.invalidate(currentProfileProvider);
    });
  }

  // Hàm đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
    });
  }
}