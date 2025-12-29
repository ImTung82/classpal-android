// File: lib/features/events/presentation/view_models/owner_event_view_model.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider lấy danh sách sự kiện theo classId
final ownerEventsProvider = FutureProvider.autoDispose
    .family<List<ClassEvent>, String>((ref, classId) async {
      return ref.watch(eventRepositoryProvider).fetchOwnerEvents(classId);
    });

// Controller xử lý action
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

      // Refresh list
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
}
