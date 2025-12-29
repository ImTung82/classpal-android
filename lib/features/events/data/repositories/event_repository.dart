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
}

class SupabaseEventRepository implements EventRepository {
  final SupabaseClient _supabase;

  SupabaseEventRepository(this._supabase);

  @override
  Future<List<ClassEvent>> fetchOwnerEvents(String classId) async {
    try {
      final response = await _supabase
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
          .order('start_time', ascending: true); // Sắp xếp theo thời gian

      return (response as List)
          .map((json) => ClassEvent.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách sự kiện: $e');
    }
  }

  @override
  Future<ClassEvent> fetchEventById(String eventId) async {
    try {
      final response = await _supabase
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

  @override
  Future<ClassEvent> createEvent(String classId, ClassEvent event) async {
    try {
      final eventData = event.toJson(classId);

      // Insert và trả về dữ liệu vừa tạo
      final response = await _supabase.from('events').insert(eventData).select(
        '''
            *,
            event_participants(
              user_id,
              status,
              profiles(full_name, avatar_url)
            )
          ''',
      ).single();

      // Tự động thêm tất cả sinh viên trong lớp vào event_participants
      // Lưu ý: Việc này có thể tốn thời gian nếu lớp đông, cân nhắc chạy background function (Edge Function) nếu cần
      await _addAllStudentsToEvent(response['id'], classId);

      // Fetch lại để có đầy đủ danh sách participants (vừa thêm vào)
      return await fetchEventById(response['id']);
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

      final participantRecords = students.map((student) {
        return {
          'event_id': eventId,
          'user_id': student['user_id'],
          'status': 'pending', // Trạng thái mặc định
        };
      }).toList();

      await _supabase.from('event_participants').insert(participantRecords);
    } catch (e) {
      print('Warning: Lỗi khi thêm sinh viên vào sự kiện: $e');
      // Không throw exception ở đây để không chặn flow tạo event chính
    }
  }

  @override
  Future<ClassEvent> updateEvent(ClassEvent event) async {
    try {
      final eventData = event.toJson(''); // classId rỗng vì không update nó
      eventData.remove('class_id'); // Loại bỏ class_id để an toàn

      // --- LOGIC CẬP NHẬT TRẠNG THÁI MỞ/ĐÓNG ---
      if (event.isOpen == false) {
        // Nếu đóng: Ghi nhận thời gian đóng là hiện tại
        eventData['end_time'] = DateTime.now().toIso8601String();
      } else {
        // Nếu mở lại: Xóa thời gian kết thúc
        eventData['end_time'] = null;
      }

      final response = await _supabase
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
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sự kiện: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      // 1. Xóa người tham gia trước (tránh Foreign Key constraint error)
      await _supabase
          .from('event_participants')
          .delete()
          .eq('event_id', eventId);

      // 2. Xóa sự kiện chính
      await _supabase.from('events').delete().eq('id', eventId);
    } catch (e) {
      throw Exception('Lỗi khi xóa sự kiện: $e');
    }
  }

  @override
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }
}
