import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return SupabaseDashboardRepository(Supabase.instance.client);
});

abstract class DashboardRepository {
  Future<List<StatData>> fetchStats(String classId);
  Future<List<DutyData>> fetchDuties(String classId);
  Future<List<EventData>> fetchEvents(String classId);

  // Student Methods
  Future<StudentTaskData?> fetchStudentTask(String classId, String userId);
  Future<List<GroupMemberData>> fetchGroupMembers(String? teamId);
}

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _supabase;
  SupabaseDashboardRepository(this._supabase);

  @override
  Future<List<StatData>> fetchStats(String classId) async {
    try {
      // 1. Lấy tổng số sinh viên trong lớp
      final studentsCount = await _supabase
          .from('class_members')
          .select('id')
          .eq('class_id', classId);

      // 2. Lấy số lượng đội nhóm (Teams) - Đây là phần bạn cần
      final teamsCount = await _supabase
          .from('teams')
          .select('id')
          .eq('class_id', classId);

      // 3. Lấy số sự kiện đang diễn ra
      final eventsCount = await _supabase
          .from('events')
          .select('id')
          .eq('class_id', classId)
          .gte('end_time', DateTime.now().toIso8601String());

      // 4. Tính toán quỹ lớp (Ví dụ đơn giản từ bảng fund_transactions)
      final fundData = await _supabase
          .from('fund_transactions')
          .select('amount, is_expense')
          .eq('class_id', classId);

      int totalFund = 0;
      for (var item in (fundData as List)) {
        if (item['is_expense'] == true) {
          totalFund -= (item['amount'] as num).toInt();
        } else {
          totalFund += (item['amount'] as num).toInt();
        }
      }

      return [
        StatData(
          "Sinh viên",
          "${(studentsCount as List).length}",
          "",
          1,
          0xFF4A84F8,
        ),
        StatData(
          "Đội nhóm",
          "${(teamsCount as List).length}",
          "",
          2,
          0xFF8B5CF6,
        ), // Thẻ team mới
        StatData(
          "Sự kiện",
          "${(eventsCount as List).length}",
          "",
          3,
          0xFFA855F7,
        ),
        StatData("Quỹ lớp", "${totalFund ~/ 1000}K", "", 4, 0xFF22C55E),
      ];
    } catch (e) {
      print("Error Dashboard Stats: $e");
      return [];
    }
  }

  @override
  Future<List<DutyData>> fetchDuties(String classId) async {
    // Lấy nhiệm vụ trực nhật, join với bảng teams để lấy tên tổ
    final data = await _supabase
        .from('duties')
        .select('*, teams(name)')
        .eq('class_id', classId)
        .order('start_time', ascending: true)
        .limit(3);

    return (data as List).map((d) {
      return DutyData(
        d['teams']?['name'] ?? "N/A",
        d['note'] ?? "Trực nhật",
        d['status'] == 'done'
            ? 'Done'
            : (d['status'] == 'pending' ? 'Upcoming' : 'In Progress'),
        "",
      );
    }).toList();
  }

  @override
  Future<List<EventData>> fetchEvents(String classId) async {
    final data = await _supabase
        .from('events')
        .select('*, event_participants(count)')
        .eq('class_id', classId)
        .limit(2);

    return (data as List).map((e) {
      final participantsCount = (e['event_participants'] as List).isEmpty
          ? 0
          : e['event_participants'][0]['count'];
      return EventData(
        e['title'],
        e['start_time'].toString().substring(0, 10),
        participantsCount,
        50, // Giả định tối đa 50 hoặc lấy từ field khác
      );
    }).toList();
  }

  @override
  Future<StudentTaskData?> fetchStudentTask(
    String classId,
    String userId,
  ) async {
    // Logic lấy nhiệm vụ của cá nhân dựa trên team_id của họ
    return StudentTaskData("Nhiệm vụ tuần này", "Đang cập nhật...");
  }

  @override
  Future<List<GroupMemberData>> fetchGroupMembers(String? teamId) async {
    if (teamId == null) return [];
    final data = await _supabase
        .from('class_members')
        .select('profiles(full_name)')
        .eq('team_id', teamId);

    return (data as List)
        .map((m) => GroupMemberData(m['profiles']['full_name'], "0xFF9CA3AF"))
        .toList();
  }
}
