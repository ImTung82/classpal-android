import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/asset_model.dart';

class AvailableAssetItem extends StatelessWidget {
  final AssetModel asset;

  const AvailableAssetItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: 12),
          Expanded(child: _info()),
          _borrowButton(),
        ],
      ),
    );
  }

  Widget _icon() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.box,
            color: Colors.green, size: 20),
      );

  Widget _info() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(asset.name,
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.w500)),
          Text(
            '${asset.assetCode} • ${asset.category}',
            style:
                GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
          ),
        ],
      );

  Widget _borrowButton() => ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Mượn'),
          );
}
