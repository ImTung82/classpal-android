import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/duty_models.dart';

final dutyRepositoryProvider = Provider<DutyRepository>((ref) {
  return SupabaseDutyRepository(Supabase.instance.client);
});

abstract class DutyRepository {
  Future<List<GroupScore>> fetchScoreBoard(String classId);
  Future<List<DutyTask>> fetchActiveDuties(String classId);
  Future<List<DutyTask>> fetchNextWeekDuties(String classId);
  Future<List<DutyTask>> fetchMyDuty(String classId, String userId);
  Future<List<DutyTask>> fetchUpcomingDuties(String classId);

  Future<void> createDutyRotation({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> taskTitles,
    List<String>? selectedTeamIds,
  });

  Future<void> markAsCompleted(String dutyId);
  Future<void> sendReminder(String dutyId);
  Future<void> deleteDutySeries(String generalId);
}

class SupabaseDutyRepository implements DutyRepository {
  final SupabaseClient _supabase;

  SupabaseDutyRepository(this._supabase);

  @override
  Future<List<GroupScore>> fetchScoreBoard(String classId) async {
    try {
      final data = await _supabase
          .from('teams')
          .select(
            'id, name, score, class_members!class_members_team_id_fkey(count)',
          )
          .eq('class_id', classId)
          .order('score', ascending: false);

      final List<dynamic> list = data as List;

      return list.asMap().entries.map((entry) {
        final index = entry.key;
        final team = entry.value;
        final countList = team['class_members'] as List;
        final memberCount = countList.isNotEmpty
            ? countList[0]['count'] as int
            : 0;

        return GroupScore(
          rank: index + 1,
          groupName: team['name'] ?? '',
          memberCount: memberCount,
          score: team['score'] ?? 0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bảng điểm: $e');
    }
  }

  @override
  Future<void> createDutyRotation({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> taskTitles,
    List<String>? selectedTeamIds,
  }) async {
    try {
      List<String> teamIds = selectedTeamIds ?? [];
      if (teamIds.isEmpty) return;

      List<Map<String, dynamic>> batchDuties = [];

      int totalDays = endDate.difference(startDate).inDays;
      int totalWeeks = (totalDays / 7).ceil() + 1;
      String general_id = const Uuid().v4();

      for (int week = 0; week < totalWeeks; week++) {
        DateTime currentStart = startDate.add(Duration(days: week * 7));
        DateTime currentEnd = currentStart.add(
          const Duration(days: 5, hours: 23, minutes: 59),
        );

        if (currentStart.isAfter(endDate)) break;

        for (int i = 0; i < taskTitles.length; i++) {
          int assignedTeamIdx = (week + i) % teamIds.length;

          batchDuties.add({
            'general_id': general_id,
            'class_id': classId,
            'team_id': teamIds[assignedTeamIdx],
            'start_time': currentStart.toUtc().toIso8601String(),
            'end_time': currentEnd.toUtc().toIso8601String(),
            'note': taskTitles[i],
            'status': 'pending',
          });
        }
      }

      await _supabase.from('duties').insert(batchDuties);
    } catch (e) {
      throw Exception('Lỗi khi tạo chu kỳ xoay vòng: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchActiveDuties(String classId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .lte('start_time', now)
          .gte('end_time', now)
          .order('created_at', ascending: false);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ tuần này: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchNextWeekDuties(String classId) async {
    try {
      final now = DateTime.now();
      int daysUntilNextMonday = 8 - now.weekday;
      DateTime nextMonday = now.add(Duration(days: daysUntilNextMonday));
      nextMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);

      DateTime nextSaturday = nextMonday.add(
        const Duration(days: 5, hours: 23, minutes: 59),
      );

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('start_time', nextMonday.toUtc().toIso8601String())
          .lte('end_time', nextSaturday.toUtc().toIso8601String())
          .order('start_time', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ tuần sau: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchMyDuty(String classId, String userId) async {
    try {
      final memberData = await _supabase
          .from('class_members')
          .select('team_id')
          .eq('class_id', classId)
          .eq('user_id', userId)
          .maybeSingle();

      if (memberData == null || memberData['team_id'] == null) return [];
      final teamId = memberData['team_id'];
      final now = DateTime.now().toUtc().toIso8601String();

      // [FIX] Removed .maybeSingle() to allow multiple tasks per week
      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .eq('team_id', teamId)
          .lte('start_time', now)
          .gte('end_time', now)
          .order('created_at', ascending: false);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ cá nhân: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchUpcomingDuties(String classId) async {
    try {
      final now = DateTime.now();
      int daysUntilNextMonday = 8 - now.weekday;
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      final nextMondayStr = DateTime(
        nextMonday.year,
        nextMonday.month,
        nextMonday.day,
      ).toUtc().toIso8601String();

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('start_time', nextMondayStr)
          .order('created_at', ascending: false)
          .order('start_time', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sắp tới: $e');
    }
  }

  @override
  Future<void> markAsCompleted(String dutyId) async {
    try {
      await _supabase
          .from('duties')
          .update({'status': 'completed'})
          .eq('id', dutyId);
    } catch (e) {
      throw Exception('Lỗi khi xác nhận hoàn thành: $e');
    }
  }

  @override
  Future<void> sendReminder(String dutyId) async {
    try {
      final dutyData = await _supabase
          .from('duties')
          .select('*, teams(id, name), classes(id, name)')
          .eq('id', dutyId)
          .single();

      final teamId = dutyData['team_id'];
      if (teamId == null) return;

      final membersData = await _supabase
          .from('class_members')
          .select('user_id')
          .eq('team_id', teamId);

      final notifications = (membersData as List)
          .map(
            (member) => {
              'user_id': member['user_id'],
              'class_id': dutyData['class_id'],
              'title': 'Nhắc nhở trực nhật',
              'body':
                  'Đã đến lịch trực nhật của tổ ${dutyData['teams']['name']} tuần này. Các bạn hãy chú ý nhé!',
              'type': 'duty_reminder',
            },
          )
          .toList();

      if (notifications.isNotEmpty) {
        await _supabase.from('notifications').insert(notifications);
      }
    } catch (e) {
      throw Exception('Lỗi khi gửi nhắc nhở: $e');
    }
  }

  @override
  Future<void> deleteDutySeries(String generalId) async {
    try {
      final List<dynamic> deletedRows = await _supabase
          .from('duties')
          .delete()
          .eq('general_id', generalId)
          .select();

      if (deletedRows.isEmpty) {
        throw Exception(
          'Không tìm thấy dữ liệu để xóa hoặc bạn không có quyền xóa (RLS).',
        );
      }
    } catch (e) {
      throw Exception('Lỗi xóa: $e');
    }
  }
}
