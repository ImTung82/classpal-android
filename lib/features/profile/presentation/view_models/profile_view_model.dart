import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/profile_repository.dart';

// Dùng AsyncNotifier thay cho StateNotifier
class ProfileViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Không cần khởi tạo gì đặc biệt, trạng thái ban đầu là null (void)
    return;
  }

  Future<void> updateProfile(String name, String phone) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.updateProfile(fullName: name, phone: phone);
    });
  }

  Future<void> changePassword(String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(profileRepositoryProvider);
      await repo.changePassword(newPassword);
    });
  }
}

final profileViewModelProvider = AsyncNotifierProvider<ProfileViewModel, void>(
  ProfileViewModel.new,
);
