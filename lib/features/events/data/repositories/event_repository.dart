import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_models.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return SupabaseEventRepository(Supabase.instance.client);
});

abstract class EventRepository {
  Future<List<ClassEvent>> fetchOwnerEvents(String classId);
  Future<ClassEvent> fetchEventById(String eventId);
  Future<ClassEvent> createEvent(String classId, ClassEvent event);
  Future<ClassEvent> updateEvent(ClassEvent event);
  Future<void> deleteEvent(String eventId);
  String? getCurrentUserId();
  Future<void> joinEvent(String eventId, String userId);
  Future<void> leaveEvent(String eventId, String userId);
}

class SupabaseEventRepository implements EventRepository {
  final SupabaseClient _supabase;
  SupabaseEventRepository(this._supabase);

  final String _selectQuery = '''
    *,
    event_participants(
      user_id,
      status,
      profiles(full_name, avatar_url)
    )
  ''';

  @override
  Future<List<ClassEvent>> fetchOwnerEvents(String classId) async {
    try {
      final response = await _supabase
          .from('events')
          .select(_selectQuery)
          .eq('class_id', classId)
          .order('updated_at', ascending: false); // Mới nhất lên đầu

      return (response as List)
          .map((json) => ClassEvent.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách sự kiện: $e');
    }
  }

  @override
  Future<ClassEvent> createEvent(String classId, ClassEvent event) async {
    try {
      final eventData = event.toJson(classId);
      final response = await _supabase
          .from('events')
          .insert(eventData)
          .select(_selectQuery)
          .single();
      final eventId = response['id'];

      await _addAllStudentsToEvent(eventId, classId);

      // Owner tự động tham gia
      final currentUserId = getCurrentUserId();
      if (currentUserId != null) {
        await joinEvent(eventId, currentUserId);
      }

      return await fetchEventById(eventId);
    } catch (e) {
      throw Exception('Lỗi khi tạo sự kiện: $e');
    }
  }

  Future<void> _addAllStudentsToEvent(String eventId, String classId) async {
    try {
      final students = await _supabase
          .from('class_members')
          .select('user_id')
          .eq('class_id', classId)
          .eq('is_active', true);
      if ((students as List).isEmpty) return;

      final participantRecords = students
          .map(
            (student) => {
              'event_id': eventId,
              'user_id': student['user_id'],
              'status': 'pending',
            },
          )
          .toList();

      await _supabase
          .from('event_participants')
          .upsert(participantRecords, onConflict: 'event_id,user_id');
    } catch (e) {
      print('Lỗi thêm sinh viên: $e');
    }
  }

  @override
  Future<ClassEvent> updateEvent(ClassEvent event) async {
    try {
      final eventData = event.toJson('');
      eventData.remove('class_id');
      final response = await _supabase
          .from('events')
          .update(eventData)
          .eq('id', event.id)
          .select(_selectQuery)
          .single();
      return ClassEvent.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi cập nhật sự kiện: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await _supabase.from('event_participants').delete().eq('event_id', eventId);
    await _supabase.from('events').delete().eq('id', eventId);
  }

  @override
  String? getCurrentUserId() => _supabase.auth.currentUser?.id;

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    await _supabase.from('event_participants').upsert({
      'event_id': eventId,
      'user_id': userId,
      'status': 'joined',
    }, onConflict: 'event_id,user_id');
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    await _supabase
        .from('event_participants')
        .update({'status': 'not_joined'})
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  @override
  Future<ClassEvent> fetchEventById(String eventId) async {
    final response = await _supabase
        .from('events')
        .select(_selectQuery)
        .eq('id', eventId)
        .single();
    return ClassEvent.fromJson(response);
  }
}
