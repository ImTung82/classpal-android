import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/class_repository.dart';
import '../../data/models/class_model.dart';

// 1. PROVIDER DANH SÁCH (Riverpod 3.x Standard)
final classListProvider = AsyncNotifierProvider.autoDispose<ClassListViewModel, List<ClassModel>>(() {
  return ClassListViewModel();
});

class ClassListViewModel extends AsyncNotifier<List<ClassModel>> {
  @override
  FutureOr<List<ClassModel>> build() async {
    return _fetchClasses();
  }

  Future<List<ClassModel>> _fetchClasses() async {
    return await ref.read(classRepositoryProvider).fetchUserClasses();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchClasses());
  }
}

// 2. PROVIDER CONTROL (CREATE / JOIN)
final classControllerProvider = NotifierProvider<ClassController, bool>(() {
  return ClassController();
});

class ClassController extends Notifier<bool> {
  @override
  bool build() => false;

  // [SỬA] Thêm tham số ownerStudentCode
  Future<void> createClass({
    required String name,
    required String schoolName,
    required String code,
    required String ownerStudentCode, // <--- MỚI
    String? description,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("Chưa đăng nhập");

      final newClass = ClassModel(
        id: '', 
        name: name,
        code: code,
        schoolName: schoolName,
        description: description,
        ownerId: user.id,
        role: 'owner',
      );

      // [SỬA] Truyền mã SV xuống Repository
      await ref.read(classRepositoryProvider).createClass(newClass, ownerStudentCode);
      
      ref.invalidate(classListProvider);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = false;
    }
  }

  Future<void> joinClass({
    required String code,
    required String studentCode,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    state = true;
    try {
      await ref.read(classRepositoryProvider).joinClass(code, studentCode);
      
      ref.invalidate(classListProvider);
      onSuccess();
    } catch (e) {
      String msg = e.toString().replaceAll("Exception: ", "");
      onError(msg);
    } finally {
      state = false;
    }
  }
}