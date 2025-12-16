import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider
final createClassRepositoryProvider = Provider<CreateClassRepository>(
  (ref) => MockCreateClassRepository(),
);

abstract class CreateClassRepository {
  Future<void> createClass(String className);
}

class MockCreateClassRepository implements CreateClassRepository {
  @override
  Future<void> createClass(String className) async {
    // 1. Giả lập delay mạng 1.5 giây
    await Future.delayed(const Duration(milliseconds: 1500));

    final cleanName = className.trim();

    // 2. Validate dữ liệu
    if (cleanName.isEmpty) {
      throw Exception("Tên lớp học không được để trống");
    }

    // Giả sử tên lớp phải có ít nhất 6 ký tự
    if (cleanName.length < 6) {
      throw Exception("Tên lớp phải có ít nhất 6 ký tự");
    }

    print("MOCK: Create Class Success -> Name: $cleanName");
  }
}
