import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider lấy danh sách (giữ nguyên cái bạn đã có)
final studentEventsProvider = FutureProvider.family<List<ClassEvent>, String>((
  ref,
  classId,
) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.fetchOwnerEvents(classId);
});

// Controller xử lý Đăng ký / Hủy
final studentEventControllerProvider =
    AsyncNotifierProvider<StudentEventController, void>(() {
      return StudentEventController();
    });

class StudentEventController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> joinEvent({
    required String classId,
    required String eventId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(eventRepositoryProvider).getCurrentUserId();
      if (userId == null) throw Exception("User not found");

      await ref.read(eventRepositoryProvider).joinEvent(eventId, userId);

      // Refresh lại danh sách sự kiện để cập nhật UI ngay lập tức
      ref.invalidate(studentEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> leaveEvent({
    required String classId,
    required String eventId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(eventRepositoryProvider).getCurrentUserId();
      if (userId == null) throw Exception("User not found");

      await ref.read(eventRepositoryProvider).leaveEvent(eventId, userId);

      // Refresh lại danh sách
      ref.invalidate(studentEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
