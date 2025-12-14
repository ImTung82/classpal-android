import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/duty_models.dart';
import '../../data/repositories/duty_repository.dart';

// Owner Providers
final scoreBoardProvider = FutureProvider<List<GroupScore>>((ref) async {
  return ref.watch(dutyRepositoryProvider).fetchScoreBoard();
});

final activeDutiesProvider = FutureProvider<List<DutyTask>>((ref) async {
  return ref.watch(dutyRepositoryProvider).fetchActiveDuties();
});

// Student Providers
final myDutyProvider = FutureProvider<DutyTask?>((ref) async {
  return ref.watch(dutyRepositoryProvider).fetchMyDuty();
});

final upcomingDutiesProvider = FutureProvider<List<DutyTask>>((ref) async {
  return ref.watch(dutyRepositoryProvider).fetchUpcomingDuties();
});