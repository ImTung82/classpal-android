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
    final cleanName = className.trim();

    if (cleanName.isEmpty) {
      throw Exception("Tên lớp học không được để trống");
    }

    print("MOCK: Create Class Success -> Name: $cleanName");
  }
}
