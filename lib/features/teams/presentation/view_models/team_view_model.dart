import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/team_model.dart';
import '../../data/repositories/team_repository.dart';

final teamGroupsProvider = FutureProvider.family<List<TeamGroup>, String>((
  ref,
  classId,
) async {
  return ref.watch(teamRepositoryProvider).fetchGroups(classId);
});

final unassignedMembersProvider =
    FutureProvider.family<List<TeamMember>, String>((ref, classId) async {
      return ref.watch(teamRepositoryProvider).fetchUnassignedMembers(classId);
    });

final teamControllerProvider = AsyncNotifierProvider<TeamController, void>(() {
  return TeamController();
});

class TeamController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  // ... (Giữ nguyên các hàm create, update, delete, assignMember, removeMember cũ)
  Future<void> createTeam({
    required String classId,
    required String name,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).createTeam(classId, name);
      ref.invalidate(teamGroupsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> updateTeam({
    required String classId,
    required String teamId,
    required String name,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).updateTeam(teamId, name);
      ref.invalidate(teamGroupsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> deleteTeam({
    required String classId,
    required String teamId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).deleteTeam(teamId);
      ref.invalidate(teamGroupsProvider(classId));
      ref.invalidate(unassignedMembersProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> assignMember({
    required String classId,
    required String memberId,
    required String teamId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(teamRepositoryProvider)
          .assignMemberToTeam(memberId, teamId);
      ref.invalidate(teamGroupsProvider(classId));
      ref.invalidate(unassignedMembersProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> removeMember({
    required String classId,
    required String memberId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).removeMemberFromTeam(memberId);
      ref.invalidate(teamGroupsProvider(classId));
      ref.invalidate(unassignedMembersProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // Chỉ định tổ trưởng
  Future<void> assignLeader({
    required String classId,
    required String teamId,
    required String memberId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).setTeamLeader(teamId, memberId);
      ref.invalidate(teamGroupsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }

  // Gỡ chức tổ trưởng
  Future<void> revokeLeader({
    required String classId,
    required String teamId,
    required Function onSuccess,
    required Function(String) onError,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref.read(teamRepositoryProvider).setTeamLeader(teamId, null);
      ref.invalidate(teamGroupsProvider(classId));
      onSuccess();
    } catch (e) {
      onError(e.toString());
    } finally {
      state = const AsyncValue.data(null);
    }
  }
}
