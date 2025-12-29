import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/asset_status_model.dart';

class AvailableAssetItem extends StatelessWidget {
  final AssetStatusModel data;

  const AvailableAssetItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final asset = data.asset;

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(asset.name, style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
                Text(
                  'Còn: ${data.availableQuantity}/${asset.totalQuantity} • ${asset.conditionStatus}',
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
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
        child: const Icon(LucideIcons.box, color: Colors.green, size: 20),
      );

  Widget _borrowButton() => ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Mượn'),
      );
}
