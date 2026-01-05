import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/duty_models.dart';
import '../../data/repositories/duty_repository.dart';

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

final isLeaderProvider = FutureProvider.family<bool, String>((
  ref,
  classId,
) async {
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) return false;

  final data = await Supabase.instance.client
      .from('class_members')
      .select('role')
      .eq('class_id', classId)
      .eq('user_id', userId)
      .maybeSingle();

  return data?['role'] == 'leader' || data?['role'] == 'owner';
});

final dutyControllerProvider = AsyncNotifierProvider<DutyController, void>(() {
  return DutyController();
});

class DutyController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // Cập nhật phương thức này để khớp với createDutyRotation trong Repository
  Future<void> createDuty({
    required String classId,
    required DateTime startDate,
    required List<String> taskTitles,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      // Gọi phương thức xoay vòng chéo mới
      await ref
          .read(dutyRepositoryProvider)
          .createDutyRotation(
            classId: classId,
            startDate: startDate,
            taskTitles: taskTitles,
          );
      ref.invalidate(activeDutiesProvider(classId));
      ref.invalidate(upcomingDutiesProvider(classId));
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

      // Invalidate các provider liên quan để cập nhật UI ngay lập tức
      ref.invalidate(myDutyProvider(classId));
      ref.invalidate(activeDutiesProvider(classId));
      ref.invalidate(scoreBoardProvider(classId));
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
