class AssetLoanModel {
  final String id;
  final String classId;
  final String assetId;
  final String borrowerId;
  final String? borrowerName; 
  final String? assetName;
  final int quantity;
  final DateTime borrowedAt;
  final DateTime? returnedAt;
  final String? note;
  final DateTime createdAt;

  const AssetLoanModel({
    required this.id,
    required this.classId,
    required this.assetId,
    required this.borrowerId,
    required this.borrowerName,
    required this.assetName,
    required this.quantity,
    required this.borrowedAt,
    required this.returnedAt,
    required this.note,
    required this.createdAt,
  });

  bool get isReturned => returnedAt != null;

  factory AssetLoanModel.fromJson(Map<String, dynamic> json) {
    return AssetLoanModel(
      id: json['id'],
      classId: json['class_id'],
      assetId: json['asset_id'],
      borrowerId: json['borrower_id'],
      assetName: (json['assets'] as Map?)?['name'] as String?,
      borrowerName:
          (json['profiles'] as Map?)?['full_name'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      borrowedAt: DateTime.parse(json['borrowed_at']),
      returnedAt: json['returned_at'] == null
          ? null
          : DateTime.parse(json['returned_at']),
      note: json['note'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
