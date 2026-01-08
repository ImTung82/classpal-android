import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/dashboard_models.dart';

class DutyListItem extends StatelessWidget {
  final DutyData data;
  const DutyListItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final bool isDone = data.status == 'Done';
    final bool isInProgress = data.status == 'In Progress';

    final Color themeColor = isDone
        ? const Color(0xFF22C55E)
        : (isInProgress ? const Color(0xFFF59E0B) : const Color(0xFF64748B));
    final Color bgColor = isDone
        ? const Color(0xFFF0FFF4)
        : (isInProgress ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC));
    final String statusText = isDone
        ? "Hoàn thành"
        : (isInProgress ? "Đang thực hiện" : "Sắp tới");

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon đại diện nhiệm vụ (VD: dùng biểu tượng danh sách)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? LucideIcons.checkCircle2 : LucideIcons.clipboardList,
              color: themeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Thông tin nhiệm vụ
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.groupName, // Tên tổ
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  data.taskName, // Tên nhiệm vụ (VD: Dọn rác, Lau bảng)
                  style: GoogleFonts.roboto(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // Nhãn trạng thái
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: GoogleFonts.roboto(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
