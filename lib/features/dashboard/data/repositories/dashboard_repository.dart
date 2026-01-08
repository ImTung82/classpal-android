import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_models.dart';
import '../../../../core/utils/currency_utils.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return SupabaseDashboardRepository(Supabase.instance.client);
});

abstract class DashboardRepository {
  Future<List<StatData>> fetchStats(String classId);
  Future<List<DutyData>> fetchDuties(String classId);
  Future<List<EventData>> fetchEvents(String classId);
  Future<List<StudentTaskData>> fetchStudentTask(String classId, String userId);
  Future<List<GroupMemberData>> fetchGroupMembers(String? teamId);
}

class SupabaseDashboardRepository implements DashboardRepository {
  final SupabaseClient _supabase;
  SupabaseDashboardRepository(this._supabase);

  @override
  Future<List<StatData>> fetchStats(String classId) async {
    try {
      final studentsCount = await _supabase
          .from('class_members')
          .select('id')
          .eq('class_id', classId);
      final teamsCount = await _supabase
          .from('teams')
          .select('id')
          .eq('class_id', classId);
      final eventsCount = await _supabase
          .from('events')
          .select('id')
          .eq('class_id', classId)
          .gte('end_time', DateTime.now().toIso8601String());

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
        ),
        StatData(
          "Sự kiện",
          "${(eventsCount as List).length}",
          "",
          3,
          0xFFA855F7,
        ),
        StatData("Quỹ lớp", CurrencyUtils.format(totalFund), "", 4, 0xFF22C55E),
      ];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<DutyData>> fetchDuties(String classId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final data = await _supabase
          .from('duties')
          .select('*, teams(name)')
          .eq('class_id', classId)
          .gte('end_time', now)
          .order('created_at', ascending: false)
          .limit(15);

      final allowedKeywords = [
        "Đổ rác",
        "Lau bảng",
        "Tắt đèn",
        "Sắp xếp bàn ghế",
      ];

      return (data as List)
          .where((d) {
            final String note = d['note']?.toString() ?? "";
            return allowedKeywords.any((keyword) => note.contains(keyword));
          })
          .map((d) {
            final String fullNote = d['note']?.toString() ?? "Trực nhật";
            String displayTaskName = fullNote.contains(':')
                ? fullNote.split(':').first.trim()
                : fullNote;
            final start = DateTime.parse(d['start_time']).toLocal();
            return DutyData(
              d['teams']?['name'] ?? "N/A",
              displayTaskName,
              d['status'] == 'completed' ? 'Done' : 'In Progress',
              "${start.day}/${start.month}",
            );
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<EventData>> fetchEvents(String classId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();

      // 1. Lấy tổng số thành viên lớp
      final membersData = await _supabase
          .from('class_members')
          .select('id')
          .eq('class_id', classId)
          .eq('is_active', true);
      final int totalInClass = (membersData as List).length;

      // 2. Lấy sự kiện chưa hết hạn đăng ký
      final data = await _supabase
          .from('events')
          .select('*, event_participants(status)')
          .eq('class_id', classId)
          .gte('registration_deadline', now) // CHỈ LẤY sự kiện còn hạn đăng ký
          .order('start_time', ascending: true);

      return (data as List).map((e) {
        final participants = e['event_participants'] as List? ?? [];
        final int joinedCount = participants
            .where((p) => p['status'] == 'joined')
            .length;

        return EventData(
          id: e['id'],
          title: e['title'] ?? 'N/A',
          date: DateFormat(
            'dd/MM/yyyy',
          ).format(DateTime.parse(e['start_time']).toLocal()),
          current: joinedCount,
          total: totalInClass,
          isOpen:
              true, // Vì đã lọc bằng gte registration_deadline nên chắc chắn là true
          isMandatory: e['is_mandatory'] ?? false,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StudentTaskData>> fetchStudentTask(
    String classId,
    String userId,
  ) async {
    try {
      final memberInfo = await _supabase
          .from('class_members')
          .select('team_id')
          .eq('class_id', classId)
          .eq('user_id', userId)
          .maybeSingle();
      if (memberInfo == null || memberInfo['team_id'] == null) return [];

      final teamId = memberInfo['team_id'];
      final now = DateTime.now().toUtc().toIso8601String();
      final dutyData = await _supabase
          .from('duties')
          .select('*')
          .eq('team_id', teamId)
          .lte('start_time', now)
          .gte('end_time', now)
          .order('created_at', ascending: false);

      return (dutyData as List).map((duty) {
        final start = DateTime.parse(duty['start_time']).toLocal();
        final end = DateTime.parse(duty['end_time']).toLocal();
        return StudentTaskData(
          id: duty['id'],
          title: duty['note'] ?? "Trực nhật",
          dateRange: "${start.day}/${start.month} - ${end.day}/${end.month}",
          isCompleted: duty['status'] == 'completed',
          status: duty['status'] == 'completed' ? 'Done' : 'Active',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<GroupMemberData>> fetchGroupMembers(String? teamId) async {
    if (teamId == null) return [];
    try {
      final teamData = await _supabase
          .from('teams')
          .select('leader_id')
          .eq('id', teamId)
          .maybeSingle();
      final String? leaderIdInTeam = teamData?['leader_id'];

      final membersData = await _supabase
          .from('class_members')
          .select('id, profiles(full_name, avatar_url)')
          .eq('team_id', teamId);

      return (membersData as List).map((m) {
        final profile = m['profiles'];
        final bool isLeader = m['id'].toString() == leaderIdInTeam?.toString();

        return GroupMemberData(
          name: profile['full_name'] ?? "Ẩn danh",
          avatarColor: "0xFF9CA3AF",
          isLeader: isLeader,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
