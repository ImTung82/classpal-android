import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum StatType { available, borrowed }

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final StatType type;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final icon = type == StatType.available
        ? LucideIcons.checkCircle
        : LucideIcons.user;
    final color =
        type == StatType.available ? Colors.green : Colors.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      GoogleFonts.roboto(fontWeight: FontWeight.w500)),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
