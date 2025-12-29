class AssetModel {
  final String id; // uuid
  final String classId; // uuid
  final String name; // text NOT NULL
  final int totalQuantity; // integer DEFAULT 1
  final String conditionStatus; // text DEFAULT 'good'
  final String? note; // text nullable
  final DateTime createdAt; // timestamptz DEFAULT now()

  const AssetModel({
    required this.id,
    required this.classId,
    required this.name,
    required this.totalQuantity,
    required this.conditionStatus,
    required this.note,
    required this.createdAt,
  });

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    return AssetModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      name: json['name'] as String,
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 1,
      conditionStatus: (json['condition_status'] as String?) ?? 'good',
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Dùng khi insert/update lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'name': name,
      'total_quantity': totalQuantity,
      'condition_status': conditionStatus,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AssetModel copyWith({
    String? id,
    String? classId,
    String? name,
    int? totalQuantity,
    String? conditionStatus,
    String? note,
    DateTime? createdAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      conditionStatus: conditionStatus ?? this.conditionStatus,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
