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
          // [CẬP NHẬT] Sắp xếp theo updated_at giảm dần để đưa sự kiện mới/sửa lên đầu
          .order('updated_at', ascending: false);

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
          .select(_selectQuery)
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

      // Bước 1: Tạo sự kiện
      final response = await _supabase
          .from('events')
          .insert(eventData)
          .select(_selectQuery)
          .single();

      final eventId = response['id'];

      // Bước 2: Thêm tất cả sinh viên vào danh sách (mặc định pending)
      await _addAllStudentsToEvent(eventId, classId);

      // [BỔ SUNG LOGIC]: Bước 3: Tự động cho người tạo (Owner) tham gia ngay lập tức
      final currentUserId = getCurrentUserId();
      if (currentUserId != null) {
        await joinEvent(eventId, currentUserId);
      }

      // Fetch lại dữ liệu mới nhất để trả về UI
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

      final participantRecords = students.map((student) {
        return {
          'event_id': eventId,
          'user_id': student['user_id'],
          'status': 'pending',
        };
      }).toList();

      // Sử dụng upsert để tránh lỗi nếu người tạo đã tồn tại trong danh sách lớp
      await _supabase
          .from('event_participants')
          .upsert(participantRecords, onConflict: 'event_id,user_id');
    } catch (e) {
      print('Warning: Lỗi khi thêm sinh viên vào sự kiện: $e');
    }
  }

  @override
  Future<ClassEvent> updateEvent(ClassEvent event) async {
    try {
      final eventData = event.toJson('');
      eventData.remove('class_id');

      // Do trigger SQL đã được bạn tạo thành công, cột updated_at sẽ tự nhảy.
      // Ở đây chỉ cần thực hiện update bình thường.

      final response = await _supabase
          .from('events')
          .update(eventData)
          .eq('id', event.id)
          .select(_selectQuery)
          .single();

      return ClassEvent.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật sự kiện: $e');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _supabase
          .from('event_participants')
          .delete()
          .eq('event_id', eventId);

      await _supabase.from('events').delete().eq('id', eventId);
    } catch (e) {
      throw Exception('Lỗi khi xóa sự kiện: $e');
    }
  }

  @override
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  @override
  Future<void> joinEvent(String eventId, String userId) async {
    try {
      // Dùng upsert: nếu đã có bản ghi thì update thành 'joined', chưa có thì tạo mới
      await _supabase.from('event_participants').upsert({
        'event_id': eventId,
        'user_id': userId,
        'status': 'joined',
      }, onConflict: 'event_id,user_id');
    } catch (e) {
      throw Exception('Lỗi khi đăng ký tham gia: $e');
    }
  }

  @override
  Future<void> leaveEvent(String eventId, String userId) async {
    try {
      await _supabase
          .from('event_participants')
          .update({'status': 'not_joined'})
          .eq('event_id', eventId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception('Lỗi khi hủy đăng ký: $e');
    }
  }
}
