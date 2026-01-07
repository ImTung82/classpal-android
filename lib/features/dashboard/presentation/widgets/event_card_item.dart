import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/dashboard_models.dart';

class EventCardItem extends StatelessWidget {
  final EventData data;
  const EventCardItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double progress = data.total == 0 ? 0 : data.current / data.total;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần trên: Icon to, Tiêu đề và Tag trạng thái
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon to tương đương Quỹ lớp
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.calendarDays,
                  color: Color(0xFF3B82F6),
                  size: 24, // Size to tương đương icon Wallet
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Tag trạng thái
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: data.isOpen
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data.isOpen ? "Đang mở" : "Đã đóng",
                            style: TextStyle(
                              color: data.isOpen
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày: ${data.date}",
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // PHẦN THEO YÊU CẦU: Thanh tiến trình và Text nằm cùng 1 hàng ngang
          Row(
            children: [
              Expanded(
                flex: 7, // Chiếm phần lớn chiều ngang
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: const Color(0xFF3B82F6),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3, // Phần text bên phải
                child: Text(
                  "${data.current}/${data.total} Sinh viên",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
