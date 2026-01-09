import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/duty_models.dart'; 

class ScoreBoardItem extends StatelessWidget {
  final GroupScore score;

  const ScoreBoardItem({super.key, required this.score});

  @override
  Widget build(BuildContext context) {
    // Top 1 sẽ có màu nền vàng nhạt, viền vàng
    final isTop1 = score.rank == 1;
    final bgColor = isTop1 ? const Color(0xFFFFFBEB) : const Color(0xFFF9FAFB);
    final borderColor = isTop1 ? const Color(0xFFFCD34D) : Colors.transparent;
    final rankColor = isTop1 ? const Color(0xFFF59E0B) : const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Rank Circle
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: rankColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text("${score.rank}", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(score.groupName, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${score.memberCount} thành viên", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          // Score
          Text("${score.score} điểm", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
        ],
      ),
    );
  }
}