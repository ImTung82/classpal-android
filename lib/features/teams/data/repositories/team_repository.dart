import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/team_models.dart';

final teamRepositoryProvider = Provider<TeamRepository>((ref) {
  return MockTeamRepository();
});

abstract class TeamRepository {
  Future<List<TeamGroup>> fetchGroups();
  Future<List<TeamMember>> fetchUnassignedMembers();
}

class MockTeamRepository implements TeamRepository {
  @override
  Future<List<TeamGroup>> fetchGroups() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TeamGroup(
        id: '1', name: 'Tổ 1', color: 0xFF0EA5E9, // Xanh dương
        members: [
          TeamMember(id: '1', name: 'Nguyễn Văn A', email: 'vana@email.com', avatarColor: '0xFF0EA5E9'),
          TeamMember(id: '2', name: 'Trần Thị B', email: 'thib@email.com', avatarColor: '0xFF0EA5E9'),
          TeamMember(id: '3', name: 'Lê Văn C', email: 'vanc@email.com', avatarColor: '0xFF0EA5E9'),
          TeamMember(id: '4', name: 'Cao Văn L', email: 'vanl@email.com', avatarColor: '0xFF0EA5E9'),
        ],
      ),
      TeamGroup(
        id: '2', name: 'Tổ 2', color: 0xFFD946EF, // Tím hồng
        members: [
          TeamMember(id: '5', name: 'Phạm Thị D', email: 'thid@email.com', avatarColor: '0xFFD946EF'),
          TeamMember(id: '6', name: 'Hoàng Văn E', email: 'vane@email.com', avatarColor: '0xFFD946EF'),
        ],
      ),
       TeamGroup(
        id: '3', name: 'Tổ 3', color: 0xFF10B981, // Xanh lá
        members: [
          TeamMember(id: '7', name: 'Đặng Văn G', email: 'vang@email.com', avatarColor: '0xFF10B981'),
          TeamMember(id: '8', name: 'Mai Thị H', email: 'thih@email.com', avatarColor: '0xFF10B981'),
        ],
      ),
      TeamGroup(
        id: '4', name: 'Tổ 4', color: 0xFFF97316, // Cam
        members: [
           TeamMember(id: '9', name: 'Đỗ Thị K', email: 'thik@email.com', avatarColor: '0xFFF97316'),
        ], 
      ),
    ];
  }

  @override
  Future<List<TeamMember>> fetchUnassignedMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      TeamMember(id: '10', name: 'Cao Văn L', email: 'vanl@email.com', avatarColor: '0xFF9CA3AF'),
      TeamMember(id: '11', name: 'Phan Thị M', email: 'thim@email.com', avatarColor: '0xFF9CA3AF'),
    ];
  }
}