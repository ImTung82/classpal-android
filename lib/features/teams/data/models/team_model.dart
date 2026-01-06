class TeamMember {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String avatarColor;
  final String? avatarUrl;
  final bool isLeader;

  TeamMember({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    required this.avatarColor,
    this.avatarUrl,
    this.isLeader = false, // Mặc định false
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] ?? {};
    return TeamMember(
      id: map['id'],
      userId: map['user_id'] ?? '',
      name: profile['full_name'] ?? 'Không tên',
      email: profile['email'] ?? '',
      avatarUrl: profile['avatar_url'],
      avatarColor: '0xFF9CA3AF',
    );
  }

  TeamMember copyWith({String? avatarColor, bool? isLeader}) {
    return TeamMember(
      id: id,
      userId: userId,
      name: name,
      email: email,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl,
      isLeader: isLeader ?? this.isLeader,
    );
  }
}

class TeamGroup {
  final String id;
  final String name;
  final int color;
  final String? leaderId;
  final List<TeamMember> members;

  TeamGroup({
    required this.id,
    required this.name,
    required this.color,
    this.leaderId,
    required this.members,
  });
}
