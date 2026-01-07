// dashboard_view_model.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../../auth/data/repositories/auth_repository.dart';

// --- Shared Providers (Dùng chung cho cả Lớp trưởng và Sinh viên) ---

/// Provider lấy danh sách sự kiện hiển thị trên Dashboard
/// Nó sẽ gọi hàm fetchEvents từ Repository để lấy dữ liệu thật (đếm joined, kiểm tra isOpen)
final eventsProvider = FutureProvider.family<List<EventData>, String>((
  ref,
  classId,
) async {
  // Lắng nghe repository và gọi hàm fetch thực tế
  return ref.watch(dashboardRepositoryProvider).fetchEvents(classId);
});

// --- Owner Providers (Dành riêng cho Quản lý/Lớp trưởng) ---

/// Provider lấy số liệu thống kê (Sinh viên, Đội nhóm, Sự kiện, Quỹ)
final statsProvider = FutureProvider.family<List<StatData>, String>((
  ref,
  classId,
) async {
  return ref.watch(dashboardRepositoryProvider).fetchStats(classId);
});

/// Provider lấy danh sách nhiệm vụ trực nhật tổng quát của các tổ
final dutiesProvider = FutureProvider.family<List<DutyData>, String>((
  ref,
  classId,
) async {
  return ref.watch(dashboardRepositoryProvider).fetchDuties(classId);
});

// --- Student Providers (Dành riêng cho Thành viên/Sinh viên) ---

/// Trả về List để hiển thị toàn bộ nhiệm vụ trực nhật đang diễn ra của cá nhân
final studentTaskProvider =
    FutureProvider.family<List<StudentTaskData>, String>((ref, classId) async {
      final authRepo = ref.watch(authRepositoryProvider);
      final currentUser = authRepo.currentUser;

      if (currentUser == null) return [];

      return ref
          .watch(dashboardRepositoryProvider)
          .fetchStudentTask(classId, currentUser.id);
    });

/// Lấy danh sách thành viên cùng tổ kèm theo flag isLeader
final groupMembersProvider = FutureProvider.family<List<GroupMemberData>, String?>((
  ref,
  teamId,
) async {
  if (teamId == null) return [];

  // Repository này đã được xử lý để so sánh leader_id và gán isLeader = true/false
  return ref.watch(dashboardRepositoryProvider).fetchGroupMembers(teamId);
});
