import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final joinClassRepositoryProvider = Provider<JoinClassRepository>(
  (ref) => MockJoinClassRepository(),
);

abstract class JoinClassRepository {
  Future<void> joinClass(String code);
}

class MockJoinClassRepository implements JoinClassRepository {
  @override
  Future<void> joinClass(String code) async {
    // Giả lập delay mạng
    await Future.delayed(const Duration(milliseconds: 1500));

    final cleanCode = code.trim();

    // Validate giả lập
    if (code.trim().isEmpty) {
      throw Exception("Mã lớp không được để trống");
    }

    // Giả sử mã lớp phải đủ 6 ký tự
    if (code.length != 6) {
      throw Exception("Mã lớp không hợp lệ (phải có ít nhất 6 ký tự)");
    }

    print("MOCK: Join Class Success -> Code: $code");
  }
}
