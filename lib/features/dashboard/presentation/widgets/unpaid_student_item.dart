import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnpaidStudentItem extends StatelessWidget {
  final String name;
  final String studentCode;
  final String totalAmount;
  final Color? avatarColor;

  const UnpaidStudentItem({
    super.key,
    required this.name,
    required this.studentCode,
    required this.totalAmount,
    this.avatarColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor =
        avatarColor ?? Colors.primaries[name.length % Colors.primaries.length];

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
          // 1. Thay thế Icon bằng Avatar Text giống GroupMemberItem
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: effectiveColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name.substring(0, 1).toUpperCase() : "?",
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Thông tin tên và mã số
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

          // 3. Số tiền nợ
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
