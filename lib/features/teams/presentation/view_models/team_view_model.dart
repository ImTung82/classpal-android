import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/team_models.dart';
import '../../data/repositories/team_repository.dart';

// Provider lấy danh sách Tổ
final teamGroupsProvider = FutureProvider<List<TeamGroup>>((ref) async {
  final repo = ref.watch(teamRepositoryProvider);
  return repo.fetchGroups();
});

// Provider lấy danh sách Chưa phân tổ
final unassignedMembersProvider = FutureProvider<List<TeamMember>>((ref) async {
  final repo = ref.watch(teamRepositoryProvider);
  return repo.fetchUnassignedMembers();
});