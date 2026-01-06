import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/duty_models.dart';
import '../../../teams/data/models/team_model.dart'; 
import '../../data/repositories/duty_repository.dart';

// Provider lấy bảng điểm (Bảng Vàng)
final scoreBoardProvider = FutureProvider.family<List<GroupScore>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchScoreBoard(classId);
});

// Provider lấy nhiệm vụ đang hoạt động (Tuần này)
final activeDutiesProvider = FutureProvider.family<List<DutyTask>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchActiveDuties(classId);
});

// Provider lấy nhiệm vụ cá nhân của người dùng hiện tại (Tuần này)
final myDutyProvider = FutureProvider.family<DutyTask?, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref.watch(dutyRepositoryProvider).fetchMyDuty(classId, userId);
});

// Provider lấy nhiệm vụ sắp tới (Dùng cho cả Student và Owner)
final upcomingDutiesProvider = FutureProvider.family<List<DutyTask>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchUpcomingDuties(classId);
});

// Provider phục vụ riêng cho mục hiển thị "Tuần sau" trên màn hình Owner
final nextWeekDutiesProvider = FutureProvider.family<List<DutyTask>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchNextWeekDuties(classId);
});

// -----------------------------------------------------------------------------
// [SỬA LỖI] LẤY THÀNH VIÊN TỔ VÀ PHÂN QUYỀN CHUẨN
// -----------------------------------------------------------------------------

/// Provider lấy danh sách thành viên CÙNG TỔ với người dùng hiện tại
final myTeamMembersProvider = FutureProvider.family<List<TeamMember>, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  // 1. Tìm thông tin member hiện tại để lấy team_id
  final currentUserMemberInfo = await Supabase.instance.client
      .from('class_members')
      .select('team_id')
      .eq('class_id', classId)
      .eq('user_id', userId)
      .maybeSingle();

  if (currentUserMemberInfo == null || currentUserMemberInfo['team_id'] == null)
    return [];
  final String teamId = currentUserMemberInfo['team_id'];

  // 2. Lấy thông tin tổ để biết leader_id (Id của class_members)
  final teamData = await Supabase.instance.client
      .from('teams')
      .select('leader_id')
      .eq('id', teamId)
      .single();
  final String? leaderIdInDb = teamData['leader_id'];

  // 3. Lấy toàn bộ thành viên trong tổ đó
  final membersData = await Supabase.instance.client
      .from('class_members')
      .select('*, profiles(*)')
      .eq('team_id', teamId);

  final List<dynamic> list = membersData as List;
  return list.map((m) {
    final member = TeamMember.fromMap(m);
    // So khớp ID class_members với leader_id của bảng teams để set cờ isLeader
    return member.copyWith(isLeader: member.id == leaderIdInDb);
  }).toList();
});

/// Provider kiểm tra quyền hạn (Owner lớp hoặc Tổ trưởng của tổ mình)
final isLeaderProvider = FutureProvider.family<bool, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return false;

  // 1. Lấy role và id member của user hiện tại
  final memberData = await Supabase.instance.client
      .from('class_members')
      .select('id, role, team_id')
      .eq('class_id', classId)
      .eq('user_id', userId)
      .maybeSingle();

  if (memberData == null) return false;

  // Quyền 1: Nếu là Owner (Lớp trưởng) -> Auto true
  if (memberData['role'] == 'owner') return true;

  // Quyền 2: Nếu là leader của team (Tổ trưởng)
  if (memberData['team_id'] != null) {
    final teamData = await Supabase.instance.client
        .from('teams')
        .select('leader_id')
        .eq('id', memberData['team_id'])
        .single();

    // So sánh ID class_members với leader_id được lưu trong bảng teams
    return teamData['leader_id'] == memberData['id'];
  }

  return false;
});

// -----------------------------------------------------------------------------
// CONTROLLER
// -----------------------------------------------------------------------------

final dutyControllerProvider = AsyncNotifierProvider<DutyController, void>(() {
  return DutyController();
});

class DutyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Tạo nhiệm vụ mới (Owner thực hiện)
  Future<void> createDuty({
    required String classId,
    required DateTime startDate,
    required DateTime endDate,
    required List<String> taskTitles,
    required List<String> selectedTeamIds,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(dutyRepositoryProvider)
          .createDutyRotation(
            classId: classId,
            startDate: startDate,
            endDate: endDate,
            taskTitles: taskTitles,
            selectedTeamIds: selectedTeamIds,
          );

      // Refresh dữ liệu
      ref.invalidate(activeDutiesProvider(classId));
      ref.invalidate(upcomingDutiesProvider(classId));
      ref.invalidate(nextWeekDutiesProvider(classId));

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// Xác nhận hoàn thành (Tổ trưởng thực hiện)
  Future<void> markAsCompleted({
    required String classId,
    required String dutyId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(dutyRepositoryProvider).markAsCompleted(dutyId);

      // Cập nhật UI ngay lập tức
      ref.invalidate(myDutyProvider(classId));
      ref.invalidate(activeDutiesProvider(classId));
      ref.invalidate(upcomingDutiesProvider(classId));
      ref.invalidate(nextWeekDutiesProvider(classId));
      ref.invalidate(scoreBoardProvider(classId));

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// Gửi nhắc nhở
  Future<void> sendReminder({
    required String classId,
    required String dutyId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(dutyRepositoryProvider).sendReminder(dutyId);
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
