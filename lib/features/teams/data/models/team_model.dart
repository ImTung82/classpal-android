class TeamMember {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String avatarColor; // Hex string (VD: "0xFF0EA5E9")
  final String? avatarUrl;

  TeamMember({
    required this.id, 
    required this.userId,
    required this.name, 
    required this.email, 
    required this.avatarColor,
    this.avatarUrl,
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    final profile = map['profiles'] ?? {};
    return TeamMember(
      id: map['id'],
      userId: map['user_id'] ?? '',
      name: profile['full_name'] ?? 'Không tên',
      email: profile['email'] ?? '',
      avatarUrl: profile['avatar_url'],
      avatarColor: '0xFF9CA3AF', // Màu mặc định (Xám)
    );
  }

  TeamMember copyWith({String? avatarColor}) {
    return TeamMember(
      id: id,
      userId: userId,
      name: name,
      email: email,
      avatarColor: avatarColor ?? this.avatarColor,
      avatarUrl: avatarUrl,
    );
  }
}

class TeamGroup {
  final String id;
  final String name;
  final int color; // Màu do Repository tính toán
  final List<TeamMember> members;

  TeamGroup({
    required this.id, 
    required this.name, 
    required this.color, 
    required this.members
  });

  factory TeamGroup.fromMap(Map<String, dynamic> map) {
    return TeamGroup(
      id: map['id'],
      name: map['name'],
      color: 0xFF0EA5E9, // Giá trị mặc định (sẽ bị ghi đè bởi Repository)
      members: [],
    );
  }
}