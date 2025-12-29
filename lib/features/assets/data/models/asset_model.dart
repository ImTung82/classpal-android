class AssetModel {
  final String name;
  final String assetCode;
  final String category;
  final String status;
  final String user;
  final String time;

  AssetModel({
    required this.name,
    required this.assetCode,
    required this.category,
    required this.status,
    required this.user,
    required this.time,
  });

  bool get isBorrowed => status == 'borrowed';
}
