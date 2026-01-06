import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/duty_models.dart';

final dutyRepositoryProvider = Provider<DutyRepository>((ref) {
  return SupabaseDutyRepository(Supabase.instance.client);
});

abstract class DutyRepository {
  Future<List<GroupScore>> fetchScoreBoard(String classId);
  Future<List<DutyTask>> fetchActiveDuties(String classId);
  Future<List<DutyTask>> fetchNextWeekDuties(
    String classId,
  ); // Lấy duy nhất tuần sau
  Future<DutyTask?> fetchMyDuty(String classId, String userId);
  Future<List<DutyTask>> fetchUpcomingDuties(String classId);

  Future<void> createDutyRotation({
    required String classId,
    required DateTime startDate,
    required DateTime endDate, // Thêm ngày kết thúc tổng quát
    required List<String> taskTitles,
    List<String>? selectedTeamIds,
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
    required DateTime startDate, // Ngày Thứ 2 người dùng chọn
    required DateTime endDate, // Ngày Thứ 7 người dùng chọn
    required List<String> taskTitles,
    List<String>? selectedTeamIds,
  }) async {
    try {
      List<String> teamIds = selectedTeamIds ?? [];
      if (teamIds.isEmpty) return;

      List<Map<String, dynamic>> batchDuties = [];

      // Tính toán số tuần thực tế từ ngày bắt đầu đến ngày kết thúc
      // Ví dụ: 12/1 (T2) -> 24/1 (T7 tuần sau) = 12 ngày chênh lệch -> ceil(12/7) + 1 = 2 tuần
      int totalDays = endDate.difference(startDate).inDays;
      int totalWeeks = (totalDays / 7).ceil() + 1;

      for (int week = 0; week < totalWeeks; week++) {
        // Ngày bắt đầu của tuần thứ i (luôn là Thứ 2)
        DateTime currentStart = startDate.add(Duration(days: week * 7));
        // Ngày kết thúc của tuần thứ i (luôn là Thứ 7)
        DateTime currentEnd = currentStart.add(
          const Duration(days: 5, hours: 23, minutes: 59),
        );

        // Kiểm tra nếu ngày bắt đầu tuần này đã vượt quá ngày kết thúc tổng quát thì dừng
        if (currentStart.isAfter(endDate)) break;

        for (int i = 0; i < taskTitles.length; i++) {
          // Xoay vòng tổ theo danh sách chọn: (Tuần hiện tại + STT công việc) % Tổng số tổ chọn
          int assignedTeamIdx = (week + i) % teamIds.length;

          batchDuties.add({
            'class_id': classId,
            'team_id': teamIds[assignedTeamIdx],
            'start_time': currentStart.toIso8601String(),
            'end_time': currentEnd.toIso8601String(),
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
      final now = DateTime.now().toIso8601String();
      // start_time <= NOW <= end_time: Chỉ lấy nhiệm vụ đang trong tuần thực hiện
      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .lte('start_time', now)
          .gte('end_time', now)
          .order('start_time', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ tuần này: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchNextWeekDuties(String classId) async {
    try {
      final now = DateTime.now();
      // Tìm Thứ 2 tuần sau
      int daysUntilNextMonday = 8 - now.weekday;
      DateTime nextMonday = now.add(Duration(days: daysUntilNextMonday));
      nextMonday = DateTime(nextMonday.year, nextMonday.month, nextMonday.day);

      // Tìm Thứ 7 tuần sau
      DateTime nextSaturday = nextMonday.add(
        const Duration(days: 5, hours: 23, minutes: 59),
      );

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('start_time', nextMonday.toIso8601String())
          .lte('end_time', nextSaturday.toIso8601String())
          .order('start_time', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ tuần sau: $e');
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
      final now = DateTime.now().toIso8601String();

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .eq('team_id', teamId)
          .lte('start_time', now)
          .gte('end_time', now)
          .maybeSingle();

      if (data == null) return null;
      return DutyTask.fromMap(data);
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ cá nhân: $e');
    }
  }

  @override
  Future<List<DutyTask>> fetchUpcomingDuties(String classId) async {
    try {
      final now = DateTime.now();
      // Chỉ lấy nhiệm vụ từ sau tuần hiện tại (bắt đầu từ T2 tuần tới trở đi)
      int daysUntilNextMonday = 8 - now.weekday;
      final nextMonday = now.add(Duration(days: daysUntilNextMonday));
      final nextMondayStr = DateTime(
        nextMonday.year,
        nextMonday.month,
        nextMonday.day,
      ).toIso8601String();

      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('start_time', nextMondayStr)
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
              'title': 'Nhắc nhở trực nhật 🧹',
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
}
