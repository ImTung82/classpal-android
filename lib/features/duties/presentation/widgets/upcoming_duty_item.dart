import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/duty_models.dart';

class UpcomingDutyItem extends StatelessWidget {
  final DutyTask task;

  const UpcomingDutyItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Phần thông tin nhiệm vụ (Bọc trong Expanded để tránh tràn viền)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF101727),
                  ),
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis, // Cắt bớt nếu tiêu đề quá dài
                ),
                const SizedBox(height: 2),
                // Hiển thị mô tả nhiệm vụ (Note)
                Text(
                  task.description,
                  style: GoogleFonts.roboto(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu mô tả quá dài
                ),
                const SizedBox(height: 4),
                // Hiển thị tổ phụ trách
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    task.assignedTo,
                    style: GoogleFonts.roboto(
                      color: Colors.blue.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12), // Khoảng cách giữa thông tin và ngày tháng
          // 2. Phần ngày tháng (Cố định độ rộng ở bên phải)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                task.dateRange,
                style: GoogleFonts.roboto(
                  color: Colors.grey[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
