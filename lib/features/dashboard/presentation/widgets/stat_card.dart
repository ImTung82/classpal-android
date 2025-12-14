import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final Color color;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subValue,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        // Viền nhẹ
        border: Border.all(color: Colors.grey.shade200),
        // Bóng đổ nhẹ
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon có nền màu
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color, 
                  borderRadius: BorderRadius.circular(8)
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              // Chỉ số tăng trưởng (màu xanh lá)
              if (subValue != null && subValue!.isNotEmpty)
                Text(
                  subValue!,
                  style: GoogleFonts.roboto(
                    color: Colors.green, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Giá trị chính (VD: 4.5M)
          Text(
            value, 
            style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 20)
          ),
          // Tiêu đề (VD: Quỹ lớp)
          Text(
            title, 
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)
          ),
        ],
      ),
    );
  }
}