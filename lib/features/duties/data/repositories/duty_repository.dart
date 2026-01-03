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

  Future<void> createDuty(
    String classId,
    String teamId,
    DateTime date,
    String? note,
  );
  Future<void> markAsCompleted(String dutyId);
  Future<void> sendReminder(String dutyId);
}

class SupabaseDutyRepository implements DutyRepository {
  final SupabaseClient _supabase;

  SupabaseDutyRepository(this._supabase);

  @override
  Future<List<GroupScore>> fetchScoreBoard(String classId) async {
    try {
      // Tối ưu: Lấy thông tin tổ và đếm số thành viên trong 1 lần gọi (Single Query)
      final data = await _supabase
          .from('teams')
          .select('id, name, score, class_members(count)')
          .eq('class_id', classId)
          .order('score', ascending: false);

      final List<dynamic> list = data as List;

      return list.asMap().entries.map((entry) {
        final index = entry.key;
        final team = entry.value;

        // Trích xuất số lượng thành viên từ kết quả join count
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
  Future<List<DutyTask>> fetchActiveDuties(String classId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Lấy nhiệm vụ trong vòng 7 ngày tới kể từ hôm nay
      final data = await _supabase
          .from('duties')
          .select('*, teams(id, name)')
          .eq('class_id', classId)
          .gte('date', today.toIso8601String())
          .lte('date', today.add(const Duration(days: 7)).toIso8601String())
          .order('date', ascending: true);

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải nhiệm vụ đang hoạt động: $e');
    }
  }

  @override
  Future<DutyTask?> fetchMyDuty(String classId, String userId) async {
    try {
      // 1. Tìm team_id của người dùng hiện tại
      final memberData = await _supabase
          .from('class_members')
          .select('team_id')
          .eq('class_id', classId)
          .eq('user_id', userId)
          .maybeSingle();

      if (memberData == null || memberData['team_id'] == null) return null;

      final teamId = memberData['team_id'];

      // 2. Tìm nhiệm vụ gần nhất của tổ đó (trong vòng 7 ngày tới)
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
      // Mốc bắt đầu là từ 00:00:00 ngày mai để không trùng với nhiệm vụ hôm nay
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
          .limit(10); // Lấy tối đa 10 nhiệm vụ tương lai

      return (data as List).map((e) => DutyTask.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi khi tải lịch sắp tới: $e');
    }
  }

  @override
  Future<void> createDuty(
    String classId,
    String teamId,
    DateTime date,
    String? note,
  ) async {
    try {
      await _supabase.from('duties').insert({
        'class_id': classId,
        'team_id': teamId,
        'date': date.toIso8601String(),
        'note': note,
        'status': 'pending',
      });
    } catch (e) {
      throw Exception('Lỗi khi tạo nhiệm vụ: $e');
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
      // 1. Lấy thông tin chi tiết nhiệm vụ
      final dutyData = await _supabase
          .from('duties')
          .select('*, teams(id, name), classes(id, name)')
          .eq('id', dutyId)
          .single();

      final teamId = dutyData['team_id'];
      if (teamId == null) return;

      // 2. Lấy danh sách thành viên trong tổ đó
      final membersData = await _supabase
          .from('class_members')
          .select('user_id')
          .eq('team_id', teamId);

      // 3. Chuẩn bị danh sách thông báo
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
