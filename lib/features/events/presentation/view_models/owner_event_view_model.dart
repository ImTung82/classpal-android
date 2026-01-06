import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider lấy danh sách sự kiện theo classId
final ownerEventsProvider = FutureProvider.autoDispose
    .family<List<ClassEvent>, String>((ref, classId) async {
      return ref.watch(eventRepositoryProvider).fetchOwnerEvents(classId);
    });

// Controller xử lý các hành động Thêm/Sửa/Xóa + [NEW] Tham gia/Hủy
final eventControllerProvider = AsyncNotifierProvider<EventController, void>(
  () => EventController(),
);

class EventController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // Tạo sự kiện
  Future<void> createEvent({
    required String classId,
    required ClassEvent event,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(eventRepositoryProvider).createEvent(classId, event);
      ref.invalidate(ownerEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // Cập nhật sự kiện
  Future<void> updateEvent({
    required String classId,
    required ClassEvent event,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(eventRepositoryProvider).updateEvent(event);
      ref.invalidate(ownerEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // Xóa sự kiện
  Future<void> deleteEvent({
    required String classId,
    required String eventId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(eventRepositoryProvider).deleteEvent(eventId);
      ref.invalidate(ownerEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // --- [NEW] THÊM LOGIC THAM GIA CHO OWNER ---
  Future<void> joinEvent({
    required String classId,
    required String eventId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      final userId = ref.read(eventRepositoryProvider).getCurrentUserId();
      if (userId == null)
        throw Exception("Không tìm thấy thông tin người dùng");

      await ref.read(eventRepositoryProvider).joinEvent(eventId, userId);
      ref.invalidate(ownerEventsProvider(classId));
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
      if (userId == null)
        throw Exception("Không tìm thấy thông tin người dùng");

      await ref.read(eventRepositoryProvider).leaveEvent(eventId, userId);
      ref.invalidate(ownerEventsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
