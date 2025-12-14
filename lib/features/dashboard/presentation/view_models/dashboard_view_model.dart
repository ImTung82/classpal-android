import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/dashboard_models.dart';
import '../../data/repositories/dashboard_repository.dart';

// Provider lấy Stats
final statsProvider = FutureProvider<List<StatData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchStats();
});

// Provider lấy Duties
final dutiesProvider = FutureProvider<List<DutyData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchDuties();
});

// Provider lấy Events
final eventsProvider = FutureProvider<List<EventData>>((ref) async {
  final repo = ref.watch(dashboardRepositoryProvider);
  return repo.fetchEvents();
});