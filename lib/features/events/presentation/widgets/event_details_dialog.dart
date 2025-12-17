import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/event_models.dart';

class EventDetailsDialog extends StatelessWidget {
  final ClassEvent event;

  const EventDetailsDialog({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // 1. Chuẩn bị danh sách các thẻ thống kê sẽ hiển thị
    // Chỉ thêm vào list nếu danh sách sinh viên tương ứng không rỗng
    List<Widget> visibleStatCards = [];

    if (event.participants.isNotEmpty) {
      visibleStatCards.add(
        Expanded(
          child: _buildStatCard(
            label: 'Tham gia',
            count: '${event.participants.length} sinh viên',
            bgColor: const Color(0xFFF0FDF4),
            labelColor: const Color(0xFF0D532B),
            countColor: const Color(0xFF00A63E),
          ),
        ),
      );
    }

    if (event.nonParticipants.isNotEmpty) {
      visibleStatCards.add(
        Expanded(
          child: _buildStatCard(
            label: 'Không tham gia',
            count: '${event.nonParticipants.length} sinh viên',
            bgColor: const Color(0xFFFEF2F2),
            labelColor: const Color(0xFF811719),
            countColor: const Color(0xFFE7000B),
          ),
        ),
      );
    }

    if (event.unconfirmed.isNotEmpty) {
      visibleStatCards.add(
        Expanded(
          child: _buildStatCard(
            label: 'Chưa xác nhận',
            count: '${event.unconfirmed.length} sinh viên',
            bgColor: const Color(0xFFFFF7ED),
            labelColor: const Color(0xFF7E2A0B),
            countColor: const Color(0xFFF54900),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề
            Text(
              event.title,
              style: GoogleFonts.arimo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF101727),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Thống kê (Hiển thị động dựa trên list visibleStatCards)
            if (visibleStatCards.isNotEmpty)
              Row(
                children: [
                  // Dùng vòng lặp để chèn SizedBox vào giữa các thẻ
                  for (int i = 0; i < visibleStatCards.length; i++) ...[
                    visibleStatCards[i],
                    // Chỉ thêm khoảng cách nếu không phải là phần tử cuối cùng
                    if (i < visibleStatCards.length - 1)
                      const SizedBox(width: 8),
                  ],
                ],
              ),

            const SizedBox(height: 24),

            // 3. Danh sách chi tiết
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Nhóm: Tham gia ---
                    if (event.participants.isNotEmpty) ...[
                      _buildSectionTitle('Sinh viên tham gia'),
                      const SizedBox(height: 12),
                      ...event.participants.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStudentItem(
                            student.name,
                            const Color(0xFFF0FDF4),
                            const Color(0xFFB8F7CF),
                            Icons.check_circle_outline,
                            const Color(0xFF00A63E),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Nhóm: Không tham gia ---
                    if (event.nonParticipants.isNotEmpty) ...[
                      _buildSectionTitle('Sinh viên không tham gia'),
                      const SizedBox(height: 12),
                      ...event.nonParticipants.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStudentItem(
                            student.name,
                            const Color(0xFFFEF2F2),
                            const Color(0xFFFFC9C9),
                            Icons.cancel_outlined,
                            const Color(0xFFE7000B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Nhóm: Chưa xác nhận ---
                    if (event.unconfirmed.isNotEmpty) ...[
                      _buildSectionTitle('Sinh viên chưa xác nhận'),
                      const SizedBox(height: 12),
                      ...event.unconfirmed.map(
                        (student) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildStudentItem(
                            student.name,
                            const Color(0xFFFFF7ED),
                            const Color(0xFFFFD6A7),
                            LucideIcons.clock,
                            const Color(0xFFF54900),
                          ),
                        ),
                      ),
                    ],

                    // Hiển thị thông báo nếu sự kiện hoàn toàn trống
                    if (event.totalCount == 0)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Chưa có dữ liệu sinh viên"),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 4. Nút Đóng
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F4F6),
                  foregroundColor: const Color(0xFF354152),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Đóng',
                  style: GoogleFonts.arimo(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatCard({
    required String label,
    required String count,
    required Color bgColor,
    required Color labelColor,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.arimo(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: labelColor,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: GoogleFonts.arimo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: countColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.arimo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF101727),
      ),
    );
  }

  Widget _buildStudentItem(
    String name,
    Color bgColor,
    Color borderColor,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: GoogleFonts.arimo(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF101727),
            ),
          ),
          Icon(icon, size: 20, color: iconColor),
        ],
      ),
    );
  }
}
