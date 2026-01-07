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

/// [CẬP NHẬT] Trả về List thay vì một item duy nhất để hiện đầy đủ nhiệm vụ
final studentTaskProvider =
    FutureProvider.family<List<StudentTaskData>, String>((ref, classId) async {
      final authRepo = ref.watch(authRepositoryProvider);
      final currentUser = authRepo.currentUser;

      if (currentUser == null) return [];

      return ref
          .watch(dashboardRepositoryProvider)
          .fetchStudentTask(classId, currentUser.id);
    });

/// [CẬP NHẬT] Lấy danh sách thành viên tổ
/// Provider này nên được watch dựa trên teamId lấy từ thông tin thành viên
final groupMembersProvider =
    FutureProvider.family<List<GroupMemberData>, String?>((ref, teamId) async {
      if (teamId == null) return [];

      // Gọi Repo để lấy thành viên kèm flag isLeader
      return ref.watch(dashboardRepositoryProvider).fetchGroupMembers(teamId);
    });
