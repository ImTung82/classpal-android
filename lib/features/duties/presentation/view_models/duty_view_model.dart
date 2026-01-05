import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/duty_models.dart';
import '../../data/repositories/duty_repository.dart';

// Owner Providers
final scoreBoardProvider = FutureProvider.family<List<GroupScore>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchScoreBoard(classId);
});

final activeDutiesProvider = FutureProvider.family<List<DutyTask>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchActiveDuties(classId);
});

// Student Providers
final myDutyProvider = FutureProvider.family<DutyTask?, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return null;
  return ref.watch(dutyRepositoryProvider).fetchMyDuty(classId, userId);
});

final upcomingDutiesProvider = FutureProvider.family<List<DutyTask>, String>((
  ref,
  classId,
) async {
  return ref.watch(dutyRepositoryProvider).fetchUpcomingDuties(classId);
});

// Controller
final dutyControllerProvider = AsyncNotifierProvider<DutyController, void>(() {
  return DutyController();
});

class DutyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> createDuty({
    required String classId,
    required String teamId,
    required DateTime date,
    String? note,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(dutyRepositoryProvider)
          .createDuty(classId, teamId, date, note);
      ref.invalidate(activeDutiesProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> markAsCompleted({
    required String classId,
    required String dutyId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(dutyRepositoryProvider).markAsCompleted(dutyId);
      ref.invalidate(myDutyProvider(classId));
      ref.invalidate(activeDutiesProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

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
