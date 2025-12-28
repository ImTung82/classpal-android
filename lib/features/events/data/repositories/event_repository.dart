import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_models.dart';
import '../services/event_supabase_service.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  final service = ref.watch(eventSupabaseServiceProvider);
  return EventRepositoryImpl(service);
});

abstract class EventRepository {
  Future<List<ClassEvent>> fetchOwnerEvents(String classId);
  Future<ClassEvent> createEvent(String classId, ClassEvent event);
  Future<ClassEvent> updateEvent(ClassEvent event);
  Future<void> deleteEvent(String eventId);
}

class EventRepositoryImpl implements EventRepository {
  final EventSupabaseService _service;

  EventRepositoryImpl(this._service);

  @override
  Future<List<ClassEvent>> fetchOwnerEvents(String classId) async {
    return await _service.fetchOwnerEvents(classId);
  }

  @override
  Future<ClassEvent> createEvent(String classId, ClassEvent event) async {
    return await _service.createEvent(classId, event);
  }

  @override
  Future<ClassEvent> updateEvent(ClassEvent event) async {
    try {
      final result = await _service.updateEvent(event);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    print('🟢 [Repository] Nhận yêu cầu xóa event: $eventId');
    try {
      await _service.deleteEvent(eventId);
    } catch (e) {
      rethrow;
    }
  }
}
