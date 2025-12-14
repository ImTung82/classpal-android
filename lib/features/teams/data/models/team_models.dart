class TeamMember {
  final String id;
  final String name;
  final String email;
  final String avatarColor; // Hex string (VD: "0xFF0EA5E9")

  TeamMember({
    required this.id, 
    required this.name, 
    required this.email, 
    required this.avatarColor
  });
}

class TeamGroup {
  final String id;
  final String name;
  final int color; // Mã màu header (Int)
  final List<TeamMember> members;

  TeamGroup({
    required this.id, 
    required this.name, 
    required this.color, 
    required this.members
  });
}