import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/asset_history_model.dart';

class HistoryItem extends StatelessWidget {
  final AssetHistoryModel history;

  const HistoryItem({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final color = history.isReturn ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            history.isReturn
                ? LucideIcons.checkCircle
                : LucideIcons.alertCircle,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(history.text,
                    style: GoogleFonts.roboto(fontSize: 13)),
                Text(history.time,
                    style: GoogleFonts.roboto(
                        fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
