import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnpaidStudentItem extends StatelessWidget {
  final String name;
  final String desc;
  final String amount;

  const UnpaidStudentItem({
    super.key, 
    required this.name, 
    required this.desc, 
    required this.amount
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(desc, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(amount, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }
}