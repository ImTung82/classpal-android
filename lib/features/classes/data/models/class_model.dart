class ClassModel {
  final String id;
  final String name;
  final String code;
  final String? schoolName;
  final String? description;
  final String ownerId;
  final String role; // 'owner' hoặc 'student'

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.schoolName,
    this.description,
    required this.ownerId,
    required this.role,
  });

  // Factory: Chuyển dữ liệu từ Supabase (JSON) -> Object Dart
  factory ClassModel.fromMap(Map<String, dynamic> json) {
    // Xử lý dữ liệu trả về từ bảng class_members (có join với classes)
    final classData = json.containsKey('classes') 
        ? json['classes'] as Map<String, dynamic> 
        : json;

    return ClassModel(
      id: classData['id'] ?? '',
      name: classData['name'] ?? '',
      code: classData['code'] ?? '',
      schoolName: classData['school_name'],
      description: classData['description'],
      ownerId: classData['owner_id'] ?? '',
      // Role nằm ở bảng class_members, nếu không có thì mặc định là owner (khi vừa tạo xong)
      role: json['role'] ?? 'owner', 
    );
  }

  // Method: Chuyển Object -> JSON (để gửi lên Supabase khi tạo lớp)
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'school_name': schoolName,
      'description': description,
      'owner_id': ownerId,
    };
  }
}