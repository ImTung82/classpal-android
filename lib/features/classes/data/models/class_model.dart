class ClassModel {
  final String id;
  final String name;
  final String code;
  final String? schoolName;
  final String? description;
  final String ownerId;
  final String role; // 'owner' hoặc 'student'
  final String? studentCode;

  ClassModel({
    required this.id,
    required this.name,
    required this.code,
    this.schoolName,
    this.description,
    required this.ownerId,
    required this.role,
    this.studentCode, 
  });

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
      role: json['role'] ?? 'owner', 
      studentCode: json['student_code'],
    );
  }

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