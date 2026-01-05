import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/duty_models.dart';

final dutyRepositoryProvider = Provider<DutyRepository>((ref) {
  return SupabaseDutyRepository(Supabase.instance.client);
});

abstract class DutyRepository {
  Future<List<GroupScore>> fetchScoreBoard(String classId);
  Future<List<DutyTask>> fetchActiveDuties(String classId);
  Future<DutyTask?> fetchMyDuty(String classId, String userId);
  Future<List<DutyTask>> fetchUpcomingDuties(String classId);

  Future<void> createDutyRotation({
    required String classId,
    required DateTime startDate,
    required List<String> taskTitles,
  });

  Future<void> markAsCompleted(String dutyId);
  Future<void> sendReminder(String dutyId);
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
    required List<String> taskTitles,
  }) async {
    try {

      final teamsData = await _supabase
          .from('teams')
          .select('id')
          .eq('class_id', classId)
          .order('created_at', ascending: true);

      final List<String> teamIds = (teamsData as List)
          .map((t) => t['id'] as String)
          .toList();

      if (teamIds.isEmpty) {
        throw Exception(
          'Không thể tạo nhiệm vụ vì lớp này chưa được chia tổ (bảng teams trống).',
        );
      }

      if (taskTitles.isEmpty) return;

      List<Map<String, dynamic>> batchDuties = [];

      for (int week = 0; week < 4; week++) {
        DateTime weekStartDate = startDate.add(Duration(days: week * 7));
        for (int i = 0; i < taskTitles.length; i++) {
          int assignedTeamIdx = (i + week) % teamIds.length;
          batchDuties.add({
            'class_id': classId,
            'team_id': teamIds[assignedTeamIdx],
            'date': weekStartDate.toIso8601String(),
            'note': taskTitles[i],
            'status': 'pending',
          });
        }
      }

      final response = await _supabase
          .from('duties')
          .insert(batchDuties)
          .select();

    } catch (e) {

      throw Exception('Lỗi khi tạo chu kỳ xoay vòng: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchActiveDuties(String classId) async {
    try {
      final now = DateTime.now();
      final firstDayMonth = DateTime(now.year, now.month, 1);
      final lastDayMonth = DateTime(now.year, now.month + 1, 0);

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('date', firstDayMonth.toIso8601String())
          .lte('date', lastDayMonth.toIso8601String())
          .order('date', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ: $e');
    }
  }

  @override
  Future<DutyTask?> fetchMyDuty(String classId, String userId) async {
    try {
      final memberData = await _supabase
          .from('class_members')
          .select('team_id')
          .eq('class_id', classId)
          .eq('user_id', userId)
          .maybeSingle();

      if (memberData == null || memberData['team_id'] == null) return null;
      final teamId = memberData['team_id'];

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .eq('team_id', teamId)
          .gte('date', today.toIso8601String())
          .lte('date', today.add(const Duration(days: 7)).toIso8601String())
          .order('date', ascending: true)
          .limit(1)
          .maybeSingle();

      if (data == null) return null;
      return DutyTask.fromMap(data);
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ của bạn: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchUpcomingDuties(String classId) async {
    try {
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
      ).add(const Duration(days: 1));

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('date', tomorrow.toIso8601String())
          .order('date', ascending: true)
          .limit(10);

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
      throw Exception('Lỗi khi đánh dấu hoàn thành: $e');
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
                  'Sắp đến lịch trực nhật của tổ ${dutyData['teams']['name']} tại lớp ${dutyData['classes']['name']}',
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
}
