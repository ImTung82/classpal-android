import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_models.dart';
import 'dart:developer' as developer;

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

  // Query cơ bản
  final String _baseSelectQuery = '''
    *,
    event_participants(
      user_id,
      status,
      profiles(full_name, avatar_url)
    )
  ''';

  // --- HÀM GHÉP DỮ LIỆU (GHÉP THỦ CÔNG) ---
  Future<List<Map<String, dynamic>>> _enrichEventsWithStudentInfo(
    List<dynamic> eventsData,
    String classId,
  ) async {
    if (eventsData.isEmpty) return [];

    // Map chứa thông tin thành viên: userId -> {student_code, team_id}
    final Map<String, Map<String, String>> memberMap = {};
    // Map chứa thông tin team: teamId -> teamName
    final Map<String, String> teamNameMap = {};

    try {
      // BƯỚC 1: Lấy danh sách thành viên (Không join bảng teams ở đây để tránh lỗi)
      final membersResponse = await _supabase
          .from('class_members')
          .select('user_id, student_code, team_id') // Lấy team_id thay vì join
          .eq('class_id', classId);

      developer.log(
        "Debug: Tìm thấy ${membersResponse.length} thành viên trong lớp $classId",
      );

      // BƯỚC 2: Lấy danh sách tên các Team trong lớp
      final teamsResponse = await _supabase
          .from('teams')
          .select('id, name')
          .eq('class_id', classId);

      // Tạo từ điển tra cứu Team Name
      for (var t in teamsResponse) {
        teamNameMap[t['id'].toString()] = t['name'].toString();
      }

      // BƯỚC 3: Tạo từ điển tra cứu Member
      for (var m in membersResponse) {
        final userId = m['user_id'].toString();
        final msv = m['student_code']?.toString() ?? 'N/A';
        final teamId = m['team_id']?.toString(); // Có thể null

        // Tự lấy tên team từ Map đã tạo ở Bước 2
        String teamName = 'Chưa phân tổ';
        if (teamId != null && teamNameMap.containsKey(teamId)) {
          teamName = teamNameMap[teamId]!;
        }

        memberMap[userId] = {'student_code': msv, 'team_name': teamName};
      }

      // Log kiểm tra user Tùng LT có trong map không (Bạn xem log console nhé)
      developer.log("Debug Map Keys: ${memberMap.keys.toList()}");
    } catch (e) {
      developer.log("Lỗi tải thông tin thành viên: $e");
    }

    // BƯỚC 4: Bơm dữ liệu vào Event
    List<Map<String, dynamic>> enrichedEvents = [];
    for (var event in eventsData) {
      final Map<String, dynamic> eventMap = Map<String, dynamic>.from(event);

      if (eventMap['event_participants'] != null) {
        final List<dynamic> rawParticipants = eventMap['event_participants'];
        final List<Map<String, dynamic>> enrichedParticipants = [];

        for (var p in rawParticipants) {
          final Map<String, dynamic> pMap = Map<String, dynamic>.from(p);
          final userId = pMap['user_id'].toString();

          if (memberMap.containsKey(userId)) {
            pMap['student_code'] = memberMap[userId]!['student_code'];
            pMap['team_name'] = memberMap[userId]!['team_name'];
          } else {
            // Nếu không tìm thấy, set rỗng để Excel nhìn đỡ bị lỗi
            developer.log(
              "Cảnh báo: User $userId tham gia sự kiện nhưng không có trong class_members",
            );
            pMap['student_code'] = '';
            pMap['team_name'] = 'Chưa phân tổ';
          }
          enrichedParticipants.add(pMap);
        }
        eventMap['event_participants'] = enrichedParticipants;
      }
      enrichedEvents.add(eventMap);
    }

    return enrichedEvents;
  }

  @override
  Future<List<ClassEvent>> fetchOwnerEvents(String classId) async {
    try {
      final response = await _supabase
          .from('events')
          .select(_baseSelectQuery)
          .eq('class_id', classId)
          .order('created_at', ascending: false)
          .order('start_time', ascending: false);

      final enrichedData = await _enrichEventsWithStudentInfo(
        response,
        classId,
      );
      return enrichedData.map((json) => ClassEvent.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi tải danh sách sự kiện: $e');
    }
  }

  @override
  Future<ClassEvent> fetchEventById(String eventId) async {
    final response = await _supabase
        .from('events')
        .select(_baseSelectQuery)
        .eq('id', eventId)
        .single();

    final classId = response['class_id'];
    final enrichedList = await _enrichEventsWithStudentInfo([
      response,
    ], classId);
    return ClassEvent.fromJson(enrichedList.first);
  }

  @override
  Future<ClassEvent> createEvent(String classId, ClassEvent event) async {
    final eventData = event.toJson(classId);
    final response = await _supabase
        .from('events')
        .insert(eventData)
        .select(_baseSelectQuery)
        .single();
    final eventId = response['id'];
    await _addAllStudentsToEvent(eventId, classId);

    return await fetchEventById(eventId);
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
      developer.log('Lỗi thêm sinh viên: $e');
    }
  }

  @override
  Future<ClassEvent> updateEvent(ClassEvent event) async {
    final eventData = event.toJson('');
    eventData.remove('class_id');
    await _supabase.from('events').update(eventData).eq('id', event.id);
    return await fetchEventById(event.id);
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
}
