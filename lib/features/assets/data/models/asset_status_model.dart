import 'asset_model.dart';

class AssetStatusModel {
  final AssetModel asset;

  /// Tổng số còn có thể mượn = total_quantity - tổng quantity của loans chưa trả
  final int availableQuantity;

  /// Nếu đang có ai mượn (ít nhất 1 loan chưa trả), show người mượn + thời gian mượn gần nhất (tuỳ query)
  final String? borrowerName;
  final DateTime? borrowedAt;
  final String? borrowerId;

  const AssetStatusModel({
    required this.asset,
    required this.availableQuantity,
    required this.borrowerName,
    required this.borrowedAt,
    required this.borrowerId,
  });

  bool get isBorrowed => availableQuantity <= 0;

  String get statusText => isBorrowed ? 'Đang mượn' : 'Có sẵn';
}
