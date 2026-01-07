// dashboard_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

// --- Owner Providers (Dành cho Quản lý/Lớp trưởng) ---

/// Provider lấy số liệu thống kê (Sinh viên, Đội nhóm, Sự kiện, Quỹ)
final statsProvider = FutureProvider.family<List<StatData>, String>((
  ref,
  classId,
) async {
  return ref.watch(dashboardRepositoryProvider).fetchStats(classId);
});

/// Provider lấy danh sách nhiệm vụ trực nhật của các tổ
final dutiesProvider = FutureProvider.family<List<DutyData>, String>((
  ref,
  classId,
) async {
  return ref.watch(dashboardRepositoryProvider).fetchDuties(classId);
});

/// Provider lấy danh sách sự kiện đang diễn ra trong lớp
final eventsProvider = FutureProvider.family<List<EventData>, String>((
  ref,
  classId,
) async {
  return ref.watch(dashboardRepositoryProvider).fetchEvents(classId);
});

// --- Student Providers (Dành cho Thành viên/Sinh viên) ---

/// Provider lấy nhiệm vụ cá nhân của sinh viên hiện tại
final studentTaskProvider = FutureProvider.family<StudentTaskData?, String>((
  ref,
  classId,
) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final currentUser = authRepo.currentUser;

  if (currentUser == null) return null;

  return ref
      .watch(dashboardRepositoryProvider)
      .fetchStudentTask(classId, currentUser.id);
});

/// Provider lấy danh sách thành viên cùng tổ với sinh viên hiện tại
/// Lưu ý: Cần truyền teamId của sinh viên đó vào
final groupMembersProvider =
    FutureProvider.family<List<GroupMemberData>, String?>((ref, teamId) async {
      if (teamId == null) return [];
      return ref.watch(dashboardRepositoryProvider).fetchGroupMembers(teamId);
    });
