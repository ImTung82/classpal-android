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
// LẤY THÀNH VIÊN TỔ VÀ PHÂN QUYỀN CHUẨN
// -----------------------------------------------------------------------------

/// Provider lấy danh sách thành viên CÙNG TỔ với người dùng hiện tại
final myTeamMembersProvider = FutureProvider.family<List<TeamMember>, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return [];

  final currentUserMemberInfo = await Supabase.instance.client
      .from('class_members')
      .select('team_id')
      .eq('class_id', classId)
      .eq('user_id', userId)
      .maybeSingle();

  if (currentUserMemberInfo == null || currentUserMemberInfo['team_id'] == null)
    return [];
  final String teamId = currentUserMemberInfo['team_id'];

  final teamData = await Supabase.instance.client
      .from('teams')
      .select('leader_id')
      .eq('id', teamId)
      .single();
  final String? leaderIdInDb = teamData['leader_id'];

  final membersData = await Supabase.instance.client
      .from('class_members')
      .select('*, profiles(*)')
      .eq('team_id', teamId);

  final List<dynamic> list = membersData as List;
  return list.map((m) {
    final member = TeamMember.fromMap(m);
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

  final memberData = await Supabase.instance.client
      .from('class_members')
      .select('id, role, team_id')
      .eq('class_id', classId)
      .eq('user_id', userId)
      .maybeSingle();

  if (memberData == null) return false;

  if (memberData['role'] == 'owner') return true;

  if (memberData['team_id'] != null) {
    final teamData = await Supabase.instance.client
        .from('teams')
        .select('leader_id')
        .eq('id', memberData['team_id'])
        .single();

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

      _refreshAllDutyProviders(classId);
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

      _refreshAllDutyProviders(classId);
      ref.invalidate(scoreBoardProvider(classId));

      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  /// [NEW] Xóa toàn bộ chu kỳ trực nhật (Owner thực hiện)
  Future<void> deleteDutySeries({
    required String classId,
    required String generalId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(dutyRepositoryProvider).deleteDutySeries(generalId);

      // Làm mới toàn bộ dữ liệu để mất các bản ghi đã xóa trên UI
      _refreshAllDutyProviders(classId);

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

  /// Hàm phụ để làm mới danh sách nhiệm vụ ở các màn hình khác nhau
  void _refreshAllDutyProviders(String classId) {
    ref.invalidate(activeDutiesProvider(classId));
    ref.invalidate(upcomingDutiesProvider(classId));
    ref.invalidate(nextWeekDutiesProvider(classId));
    ref.invalidate(myDutyProvider(classId));
  }
}
