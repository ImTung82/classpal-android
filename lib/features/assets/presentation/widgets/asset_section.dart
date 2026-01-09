import 'package:flutter/material.dart';
import '../../data/models/asset_status_model.dart';
import 'available_asset_item.dart';
import 'borrowed_asset_item.dart';

class AssetSection extends StatelessWidget {
  final String classId;
  final String title;
  final List<AssetStatusModel> assets;
  final bool isBorrowed;

  const AssetSection._({
    required this.classId,
    required this.title,
    required this.assets,
    required this.isBorrowed,
  });

  factory AssetSection.available({
    required String classId,
    required String title,
    required List<AssetStatusModel> assets,
  }) =>
      AssetSection._(
        classId: classId,
        title: title,
        assets: assets,
        isBorrowed: false,
      );

  factory AssetSection.borrowed({
    required String classId,
    required String title,
    required List<AssetStatusModel> assets,
  }) =>
      AssetSection._(
        classId: classId,
        title: title,
        assets: assets,
        isBorrowed: true,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBorrowed ? const Color(0xFFFFFBF5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBorrowed ? const Color(0xFFFFEDD5) : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(
            children: assets.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: isBorrowed
                    ? BorrowedAssetItem(classId: classId, data: item)
                    : AvailableAssetItem(classId: classId, data: item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
