import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final Color color;
  final IconData icon;

  const StatCard({super.key, required this.title, required this.value, this.subValue, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              if (subValue != null && subValue!.isNotEmpty)
                Text(subValue!, style: GoogleFonts.roboto(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const Spacer(),
          Text(value, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20)),
          Text(title, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}