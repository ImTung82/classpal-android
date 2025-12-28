import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider lấy danh sách sự kiện theo classId (giống teamGroupsProvider)
// Dùng autoDispose để cache tự động bị hủy khi không còn màn hình nào lắng nghe
final ownerEventsProvider = FutureProvider.autoDispose
    .family<List<ClassEvent>, String>((ref, classId) async {
      return ref.watch(eventRepositoryProvider).fetchOwnerEvents(classId);
    });

// Controller để xử lý các action (Create, Update, Delete)
final eventControllerProvider = AsyncNotifierProvider<EventController, void>(
  () {
    return EventController();
  },
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

      // Làm mới danh sách sự kiện của lớp này
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
    print('🟡 [Controller] === BẮT ĐẦU UPDATE ===');
    print('🟡 [Controller] Event ID: ${event.id}');
    print('🟡 [Controller] Class ID: $classId');
    print('🟡 [Controller] isOpen: ${event.isOpen}');

    state = const AsyncValue.loading();

    try {
      print('🟡 [Controller] Gọi repository.updateEvent...');
      await ref.read(eventRepositoryProvider).updateEvent(event);

      print('✅ [Controller] Repository update thành công');
      print('🟡 [Controller] Invalidating provider...');

      ref.invalidate(ownerEventsProvider(classId));

      print('✅ [Controller] Đã invalidate provider');
      print('🟡 [Controller] Gọi onSuccess callback...');

      onSuccess();

      print('✅ [Controller] === KẾT THÚC UPDATE ===');
    } catch (e) {
      print('❌ [Controller] LỖI: $e');
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
    print('🟡 [Controller] === BẮT ĐẦU XÓA ===');
    print('🟡 [Controller] Event ID: $eventId');
    print('🟡 [Controller] Class ID: $classId');

    state = const AsyncValue.loading();

    try {
      print('🟡 [Controller] Gọi repository.deleteEvent...');
      await ref.read(eventRepositoryProvider).deleteEvent(eventId);

      print('✅ [Controller] Repository xóa thành công');
      print('🟡 [Controller] Invalidating provider...');

      ref.invalidate(ownerEventsProvider(classId));

      print('✅ [Controller] Đã invalidate provider');
      await Future.delayed(const Duration(milliseconds: 100));

      print('🟡 [Controller] Gọi onSuccess callback...');
      onSuccess();

      print('✅ [Controller] === KẾT THÚC XÓA ===');
    } catch (e) {
      print('❌ [Controller] LỖI: $e');
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
