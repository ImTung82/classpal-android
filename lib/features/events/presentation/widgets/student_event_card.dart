import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // [IMPORT FONT]
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/event_models.dart';

class StudentEventCard extends StatelessWidget {
  final ClassEvent event;

  const StudentEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16), // Giảm margin bottom cho gọn
      padding: const EdgeInsets.all(
        20,
      ), // Padding 20 giống GroupCard của Teams (nếu có)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Bo góc 16 giống GroupCard
        // Viền xanh nhạt
        border: Border.all(color: const Color(0xFFB8F7CF), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Tiêu đề + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  // [CẬP NHẬT] Font Roboto, Size 16, Bold giống tên Tổ
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101727),
                    height: 1.3,
                  ),
                ),
              ),
              if (event.isMandatory)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE2E2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Bắt buộc',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: const Color(0xFFC10007),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. Mô tả (Body Text)
          Text(
            event.description,
            // [CẬP NHẬT] Size 14, màu xám đậm (giống style Teams)
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Thông tin chi tiết
          _buildInfoRow(LucideIcons.calendar, event.date),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.clock, event.time),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.mapPin, event.location),

          const SizedBox(height: 20),

          // 4. Hành động
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey), // Icon màu Grey
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            // [CẬP NHẬT] Size 13, màu Grey
            style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection() {
    if (event.status == EventStatus.registered) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              border: Border.all(color: const Color(0xFFB8F7CF)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check, size: 16, color: Color(0xFF008235)),
                const SizedBox(width: 8),
                Text(
                  'Đã đăng ký',
                  style: GoogleFonts.roboto(
                    color: const Color(0xFF008235),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(
                  0xFFEF4444,
                ), // Màu đỏ chuẩn Tailwind
                side: const BorderSide(color: Color(0xFFFECACA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: const Color(0xFFFEF2F2),
              ),
              child: Text(
                'Hủy đăng ký',
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (event.status == EventStatus.participated) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(
            0xFF10B981,
          ), // Xanh Emerald (giống màu Tổ 3 trong Teams)
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            '✓ Đã tham gia',
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Upcoming
    return SizedBox(
      width: double.infinity,
      height: 44, // Chiều cao chuẩn nút bấm
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF407CFF), // Giữ màu brand
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          'Đăng ký tham gia',
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
