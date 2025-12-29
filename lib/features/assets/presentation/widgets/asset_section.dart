import 'package:flutter/material.dart';
import '../../data/models/asset_model.dart';
import 'available_asset_item.dart';
import 'borrowed_asset_item.dart';

class AssetSection extends StatelessWidget {
  final String title;
  final List<AssetModel> assets;
  final bool isBorrowed;

  const AssetSection._({
    required this.title,
    required this.assets,
    required this.isBorrowed,
  });

  factory AssetSection.available({
    required String title,
    required List<AssetModel> assets,
  }) =>
      AssetSection._(
        title: title,
        assets: assets,
        isBorrowed: false,
      );

  factory AssetSection.borrowed({
    required String title,
    required List<AssetModel> assets,
  }) =>
      AssetSection._(
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
          color: isBorrowed
              ? const Color(0xFFFFEDD5)
              : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(
            children: assets.map((asset) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: isBorrowed
                    ? BorrowedAssetItem(asset: asset)
                    : AvailableAssetItem(asset: asset),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
