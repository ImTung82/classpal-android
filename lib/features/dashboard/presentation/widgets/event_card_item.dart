import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/dashboard_models.dart';

class EventCardItem extends StatelessWidget {
  final EventData data;
  const EventCardItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Tính toán tỷ lệ phần trăm tiến độ (0.0 đến 1.0)
    double progress = data.total == 0 ? 0 : data.current / data.total;

    // 2. Xác định màu sắc và nội dung dựa trên trạng thái isOpen
    final bool isOpen = data.isOpen;
    final Color statusBgColor = isOpen
        ? const Color(0xFFDCFCE7)
        : const Color(0xFFF3F4F6);
    final Color statusTextColor = isOpen
        ? const Color(0xFF166534)
        : const Color(0xFF6B7280);
    final String statusText = isOpen ? "Đang mở" : "Đã đóng";

    // Màu sắc thanh tiến độ: Xanh dương nếu đang mở, Xám nếu đã đóng
    final Color progressColor = isOpen
        ? const Color(0xFF2B7FFF)
        : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tiêu đề và ngày diễn ra
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày: ${data.date}",
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Nhãn trạng thái (Badge)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.roboto(
                    color: statusTextColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- PHẦN PROGRESS BAR GIỐNG OWNER ---
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${data.current}/${data.total} Sinh viên",
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
