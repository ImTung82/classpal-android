import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';

// Owner Providers
final statsProvider = FutureProvider<List<StatData>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchStats();
});

final dutiesProvider = FutureProvider<List<DutyData>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchDuties();
});

final eventsProvider = FutureProvider<List<EventData>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchEvents();
});

// Student Providers
final studentTaskProvider = FutureProvider<StudentTaskData>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchStudentTask();
});

final groupMembersProvider = FutureProvider<List<GroupMemberData>>((ref) async {
  return ref.watch(dashboardRepositoryProvider).fetchGroupMembers();
});