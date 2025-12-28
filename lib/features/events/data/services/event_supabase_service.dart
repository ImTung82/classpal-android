import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_models.dart';

final eventSupabaseServiceProvider = Provider<EventSupabaseService>((ref) {
  return EventSupabaseService(Supabase.instance.client);
});

class EventSupabaseService {
  final SupabaseClient _client;

  EventSupabaseService(this._client);

  // Lấy danh sách sự kiện của một lớp
  Future<List<ClassEvent>> fetchOwnerEvents(String classId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            event_participants(
              user_id,
              status,
              profiles(full_name, avatar_url)
            )
          ''')
          .eq('class_id', classId)
          .order('start_time', ascending: true);

      return (response as List)
          .map((json) => ClassEvent.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách sự kiện: $e');
    }
  }

  // Tạo sự kiện mới
  Future<ClassEvent> createEvent(String classId, ClassEvent event) async {
    try {
      final eventData = event.toJson(classId);

      final response = await _client.from('events').insert(eventData).select('''
            *,
            event_participants(
              user_id,
              status,
              profiles(full_name, avatar_url)
            )
          ''').single();

      // Tự động thêm tất cả sinh viên trong lớp vào event_participants
      await _addAllStudentsToEvent(response['id'], classId);

      // Fetch lại để có đầy đủ danh sách participants
      return await fetchEventById(response['id']);
    } catch (e) {
      throw Exception('Lỗi khi tạo sự kiện: $e');
    }
  }

  // Thêm tất cả sinh viên vào sự kiện
  Future<void> _addAllStudentsToEvent(String eventId, String classId) async {
    try {
      final students = await _client
          .from('class_members')
          .select('user_id')
          .eq('class_id', classId)
          .eq('is_active', true);

      final participantRecords = (students as List).map((student) {
        return {
          'event_id': eventId,
          'user_id': student['user_id'],
          'status': 'pending',
        };
      }).toList();

      if (participantRecords.isNotEmpty) {
        await _client.from('event_participants').insert(participantRecords);
      }
    } catch (e) {
      throw Exception('Lỗi khi thêm sinh viên vào sự kiện: $e');
    }
  }

  // Lấy chi tiết một sự kiện
  Future<ClassEvent> fetchEventById(String eventId) async {
    try {
      final response = await _client
          .from('events')
          .select('''
            *,
            event_participants(
              user_id,
              status,
              profiles(full_name, avatar_url)
            )
          ''')
          .eq('id', eventId)
          .single();

      return ClassEvent.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi tải chi tiết sự kiện: $e');
    }
  }

  // Cập nhật sự kiện
  Future<ClassEvent> updateEvent(ClassEvent event) async {

    try {
      final eventData = event.toJson('');
      eventData.remove('class_id');

      // --- LOGIC MỚI: HỖ TRỢ CHUYỂN ĐỔI 2 CHIỀU ---
      if (event.isOpen == false) {
        // Đóng sự kiện: Set end_time = hiện tại
        eventData['end_time'] = DateTime.now().toIso8601String();
      } else if (event.isOpen == true) {
        // Mở lại sự kiện: LUÔN XÓA end_time (không cần check containsKey)
        eventData.remove('end_time');
      }

      print('📤 [Service] Dữ liệu gửi: $eventData');

      final response = await _client
          .from('events')
          .update(eventData)
          .eq('id', event.id)
          .select('''
            *,
            event_participants(
              user_id,
              status,
              profiles(full_name, avatar_url)
            )
          ''')
          .single();
      return ClassEvent.fromJson(response);
    } catch (e, stackTrace) {
      throw Exception('Lỗi: $e');
    }
  }

  // Xóa sự kiện
  Future<void> deleteEvent(String eventId) async {

    try {

      final result = await _client.from('events').delete().eq('id', eventId);

    } catch (e, stackTrace) {
      throw Exception('Lỗi khi xóa sự kiện: $e');
    }
  }

  // Lấy user ID hiện tại
  String? getCurrentUserId() {
    return _client.auth.currentUser?.id;
  }
}
