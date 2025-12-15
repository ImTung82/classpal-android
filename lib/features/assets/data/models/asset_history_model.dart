class AssetHistoryModel {
  final String text;
  final String time;
  final String type;

  AssetHistoryModel({
    required this.text,
    required this.time,
    required this.type,
  });

  bool get isReturn => type == 'return';
}
