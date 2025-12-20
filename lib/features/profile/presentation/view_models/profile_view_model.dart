import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';

// Khai báo Provider kiểu mới (Riverpod 3.0)
final profileViewModelProvider = AsyncNotifierProvider<ProfileViewModel, void>(
  ProfileViewModel.new,
);

// Class ViewModel kế thừa AsyncNotifier (thay vì StateNotifier)
class ProfileViewModel extends AsyncNotifier<void> {
  // Hàm build() là bắt buộc để khởi tạo state ban đầu
  @override
  Future<void> build() async {
    // Trả về void (tương đương AsyncData(null)) để khởi tạo
    return;
  }

  // Helper để lấy Repo (Trong AsyncNotifier có sẵn `ref`)
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  // Hàm update profile
  Future<void> updateProfile({
    required String name,
    required String phone,
    File? imageFile,
  }) async {
    // Set state loading
    state = const AsyncValue.loading();

    // Bắt đầu xử lý logic -> guard sẽ tự catch lỗi và set AsyncError nếu fail
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
    });
  }

  // Hàm đổi mật khẩu
  Future<void> changePassword(String newPassword) async {
    state = const AsyncValue.loading();
    // Giả sử repo có hàm changePassword, nếu chưa có thì mock tạm
    state = await AsyncValue.guard(() async {
      // await _repo.changePassword(newPassword);
      // Tạm thời giả lập delay
      await Future.delayed(const Duration(seconds: 1));
    });
  }
}
