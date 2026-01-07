import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class UnpaidStudentItem extends StatelessWidget {
  final String name;
  final String studentCode;
  final String totalAmount; // Tổng tiền cộng dồn của SV này

  const UnpaidStudentItem({
    super.key,
    required this.name,
    required this.studentCode,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon người dùng bổ trợ giống style Student Dashboard
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.user,
              color: Color(0xFF64748B),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "MSSV: $studentCode",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            totalAmount,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE53E3E), 
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
