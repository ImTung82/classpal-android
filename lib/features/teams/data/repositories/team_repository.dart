import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/team_model.dart';

// Bảng màu cố định
const List<int> _kTeamColors = [
  0xFF0EA5E9, // Xanh Sky
  0xFFD946EF, // Tím Fuchsia
  0xFF10B981, // Xanh Emerald
  0xFFF97316, // Cam Orange
  0xFFEF4444, // Đỏ Red
  0xFF8B5CF6, // Tím Violet
  0xFFEAB308, // Vàng Yellow
  0xFF6366F1, // Indigo
];

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return SupabaseTeamRepository(Supabase.instance.client);
});

abstract class TeamRepository {
  Future<List<TeamGroup>> fetchGroups(String classId);
  Future<List<TeamMember>> fetchUnassignedMembers(String classId);
  
  // Lưu ý: Đã xóa tham số 'color' ở create và update
  Future<void> createTeam(String classId, String name);
  Future<void> updateTeam(String teamId, String name);
  Future<void> deleteTeam(String teamId);
  
  Future<void> assignMemberToTeam(String memberId, String teamId);
  Future<void> removeMemberFromTeam(String memberId);
}

class SupabaseTeamRepository implements TeamRepository {
  final SupabaseClient _supabase;

  SupabaseTeamRepository(this._supabase);

  @override
  Future<List<TeamGroup>> fetchGroups(String classId) async {
    try {
      // 1. Lấy danh sách tổ, sắp xếp theo ngày tạo
      final teamsData = await _supabase
          .from('teams')
          .select()
          .eq('class_id', classId)
          .order('created_at', ascending: true);

      // 2. Map dữ liệu và GÁN MÀU TỰ ĐỘNG
      final List<TeamGroup> groups = [];
      final listData = teamsData as List;

      for (int i = 0; i < listData.length; i++) {
        final item = listData[i];
        
        // Logic: Lấy màu theo thứ tự vòng lặp
        final int assignedColor = _kTeamColors[i % _kTeamColors.length];

        groups.add(TeamGroup(
          id: item['id'],
          name: item['name'],
          color: assignedColor, // <--- Màu được gán tại đây
          members: [],
        ));
      }

      // 3. Lấy thành viên và phân vào tổ
      final membersData = await _supabase
          .from('class_members')
          .select('*, profiles(id, full_name, email, avatar_url)')
          .eq('class_id', classId)
          .not('team_id', 'is', null);

      for (var group in groups) {
        final groupMembersData = (membersData as List).where((m) => m['team_id'] == group.id).toList();
        
        // Tạo mã màu Hex cho avatar thành viên dựa trên màu tổ
        final String hexColor = '0xFF${group.color.toRadixString(16).padLeft(6, '0').toUpperCase()}';

        final members = groupMembersData.map((m) {
          final rawMember = TeamMember.fromMap(m);
          return rawMember.copyWith(avatarColor: hexColor);
        }).toList();

        group.members.addAll(members);
      }

      return groups;
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách tổ: $e');
    }
  }

  @override
  Future<List<TeamMember>> fetchUnassignedMembers(String classId) async {
    try {
      final data = await _supabase
          .from('class_members')
          .select('*, profiles(id, full_name, email, avatar_url)')
          .eq('class_id', classId)
          .filter('team_id', 'is', null);

      return (data as List).map((e) => TeamMember.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Lỗi: $e');
    }
  }

  @override
  Future<void> createTeam(String classId, String name) async {
    // Không gửi color lên DB nữa
    await _supabase.from('teams').insert({
      'class_id': classId,
      'name': name,
    });
  }

  @override
  Future<void> updateTeam(String teamId, String name) async {
    // Không gửi color lên DB nữa
    await _supabase.from('teams').update({
      'name': name,
    }).eq('id', teamId);
  }

  @override
  Future<void> deleteTeam(String teamId) async {
    await _supabase.from('class_members').update({'team_id': null}).eq('team_id', teamId);
    await _supabase.from('teams').delete().eq('id', teamId);
  }

  @override
  Future<void> assignMemberToTeam(String memberId, String teamId) async {
    await _supabase.from('class_members').update({'team_id': teamId}).eq('id', memberId);
  }

  @override
  Future<void> removeMemberFromTeam(String memberId) async {
    await _supabase.from('class_members').update({'team_id': null}).eq('id', memberId);
  }
}