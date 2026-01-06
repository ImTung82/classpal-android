import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_model.dart';

const List<int> _kTeamColors = [
  0xFF0EA5E9,
  0xFFD946EF,
  0xFF10B981,
  0xFFF97316,
  0xFFEF4444,
  0xFF8B5CF6,
  0xFFEAB308,
  0xFF6366F1,
];

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return SupabaseTeamRepository(Supabase.instance.client);
});

abstract class TeamRepository {
  Future<List<TeamGroup>> fetchGroups(String classId);
  Future<List<TeamMember>> fetchUnassignedMembers(String classId);

  Future<void> createTeam(String classId, String name);
  Future<void> updateTeam(String teamId, String name);
  Future<void> deleteTeam(String teamId);

  Future<void> assignMemberToTeam(String memberId, String teamId);
  Future<void> removeMemberFromTeam(String memberId);

  // Set/Remove Leader
  Future<void> setTeamLeader(String teamId, String? memberId);
}

class SupabaseTeamRepository implements TeamRepository {
  final SupabaseClient _supabase;
  SupabaseTeamRepository(this._supabase);

  @override
  Future<List<TeamGroup>> fetchGroups(String classId) async {
    try {
      // 1. Lấy teams (Kèm cột leader_id)
      final teamsData = await _supabase
          .from('teams')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: true);

      final List<TeamGroup> groups = [];
      final listData = teamsData as List;

      for (int i = 0; i < listData.length; i++) {
        final item = listData[i];
        final int assignedColor = _kTeamColors[i % _kTeamColors.length];

        groups.add(
          TeamGroup(
            id: item['id'],
            name: item['name'],
            color: assignedColor,
            leaderId: item['leader_id']?.toString(), // [MỚI] Map từ DB
            members: [],
          ),
        );
      }

      // 2. Lấy members
      final membersData = await _supabase
          .from('class_members')
          .select('*, profiles(id, full_name, email, avatar_url)')
          .eq('class_id', classId)
          .not('team_id', 'is', null);

      // 3. Map members vào groups
      for (var group in groups) {
        final groupMembersData = (membersData as List)
            .where((m) => m['team_id'] == group.id)
            .toList();
        final String hexColor =
            '0xFF${group.color.toRadixString(16).padLeft(6, '0').toUpperCase()}';

        final members = groupMembersData.map((m) {
          final rawMember = TeamMember.fromMap(m);
          // [LOGIC] Check xem member này có phải leader không
          final isLeader = (rawMember.id == group.leaderId);

          return rawMember.copyWith(
            avatarColor: hexColor,
            isLeader: isLeader, // Set cờ
          );
        }).toList();

        // [UX] Sắp xếp: Tổ trưởng lên đầu danh sách
        members.sort((a, b) => (b.isLeader ? 1 : 0) - (a.isLeader ? 1 : 0));

        group.members.addAll(members);
      }
      return groups;
    } catch (e) {
      throw Exception('Lỗi tải danh sách: $e');
    }
  }

  // ... (Giữ nguyên các hàm fetchUnassigned, create, update, delete, assignMember, removeMember)
  @override
  Future<List<TeamMember>> fetchUnassignedMembers(String classId) async {
    final data = await _supabase
        .from('class_members')
        .select('*, profiles(*)')
        .eq('class_id', classId)
        .filter('team_id', 'is', null);
    return (data as List).map((e) => TeamMember.fromMap(e)).toList();
  }

  @override
  Future<void> createTeam(String classId, String name) async {
    await _supabase.from('teams').insert({'class_id': classId, 'name': name});
  }

  @override
  Future<void> updateTeam(String teamId, String name) async {
    await _supabase.from('teams').update({'name': name}).eq('id', teamId);
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    await _supabase
        .from('class_members')
        .update({'team_id': null})
        .eq('team_id', teamId);
    await _supabase.from('teams').delete().eq('id', teamId);
  }

  @override
  Future<void> assignMemberToTeam(String memberId, String teamId) async {
    await _supabase
        .from('class_members')
        .update({'team_id': teamId})
        .eq('id', memberId);
  }

  @override
  Future<void> removeMemberFromTeam(String memberId) async {
    await _supabase
        .from('class_members')
        .update({'team_id': null})
        .eq('id', memberId);
  }

  // [MỚI] Triển khai hàm setTeamLeader
  @override
  Future<void> setTeamLeader(String teamId, String? memberId) async {
    await _supabase
        .from('teams')
        .update({
          'leader_id': memberId, // Null nếu muốn gỡ chức
        })
        .eq('id', teamId);
  }
}
