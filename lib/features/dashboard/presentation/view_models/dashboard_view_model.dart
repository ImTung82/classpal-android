import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';

// Provider lấy Stats (Lớp trưởng)
final statsProvider = FutureProvider<List<StatData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchStats();
});

// Provider lấy Duties (Lớp trưởng)
final dutiesProvider = FutureProvider<List<DutyData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchDuties();
});

// Provider lấy Events (Lớp trưởng)
final eventsProvider = FutureProvider<List<EventData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchEvents();
});

// Provider lấy Nhiệm vụ cá nhân (Sinh viên)
final studentTaskProvider = FutureProvider<StudentTaskData>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchStudentTask();
});

// Provider lấy Danh sách thành viên tổ (Sinh viên)
final groupMembersProvider = FutureProvider<List<GroupMemberData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchGroupMembers();
});