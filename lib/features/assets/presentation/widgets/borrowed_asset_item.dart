import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/asset_model.dart';

class BorrowedAssetItem extends StatelessWidget {
  final AssetModel asset;

  const BorrowedAssetItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC99)),
      ),
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: 12),
          Expanded(child: _info()),
          _returnButton(),
        ],
      ),
    );
  }

  Widget _icon() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.user,
            color: Colors.orange, size: 18),
      );

  Widget _info() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(asset.name,
              style:
                  GoogleFonts.roboto(fontWeight: FontWeight.w500)),
          Text(
            '${asset.user} • ${asset.time}',
            style:
                GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
          ),
        ],
      );

  Widget _returnButton() => ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Trả'),
            );
}
