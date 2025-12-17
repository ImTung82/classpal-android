// File: lib/features/events/presentation/widgets/owner_event_card.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/event_models.dart';

class OwnerEventCard extends StatelessWidget {
  final ClassEvent event;

  const OwnerEventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          // 1. HEADER ROW: [Title] ... [Tags] [Icons]
          // Tất cả nằm trên 1 hàng ngang
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Căn giữa theo chiều dọc
            children: [
              // A. Title (Chiếm phần lớn diện tích bên trái)
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1, // Bắt buộc 1 dòng
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu dài
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101727),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // B. Stacked Tags (Tag chữ dọc)
              // Sử dụng Row min để các tag nằm cạnh nhau
              if (event.isMandatory || event.isOpen)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (event.isMandatory) ...[
                      _buildStackedStatusChip(
                        'Bắt',
                        'buộc',
                        const Color(0xFFFFE2E2),
                        const Color(0xFFC10007),
                      ),
                      const SizedBox(width: 6),
                    ],
                    if (event.isOpen)
                      _buildStackedStatusChip(
                        'Đang',
                        'mở',
                        const Color(0xFFDCFCE7),
                        const Color(0xFF008235),
                      ),
                  ],
                ),

              const SizedBox(width: 12),

              // C. Action Icons (Luôn nằm góc phải)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildActionButton(LucideIcons.pencil, Colors.blue, () {}),
                  const SizedBox(width: 4),
                  _buildActionButton(LucideIcons.trash2, Colors.red, () {}),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Description
          Text(
            event.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF495565),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // 3. Date & Time Rows
          Row(
            children: [
              Flexible(child: _buildInfoRow(LucideIcons.calendar, event.date)),
              const SizedBox(width: 24),
              Flexible(child: _buildInfoRow(LucideIcons.clock, event.time)),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: event.progress,
                    backgroundColor: const Color(0xFFE5E7EB),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2B7FFF),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${event.registeredCount}/${event.totalCount}",
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 5. Statistic Cards
          Row(
            children: [
              Expanded(
                child: _buildStatisticCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF0D532B),
                  title: "Đã đăng ký",
                  count: "${event.registeredCount} sinh viên",
                  countColor: const Color(0xFF00A63E),
                  backgroundColor: const Color(0xFFF0FDF4),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatisticCard(
                  icon: Icons.cancel,
                  iconColor: const Color(0xFF7E2A0B),
                  title: "Chưa đăng ký",
                  count: "${event.unregisteredCount} sinh viên",
                  countColor: const Color(0xFFF54900),
                  backgroundColor: const Color(0xFFFFF7ED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 6. Action Buttons
          _buildFullWidthButton(
            text: 'Xem chi tiết',
            icon: LucideIcons.users,
            isOutlined: true,
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _buildFullWidthButton(
            text: 'Gửi nhắc nhở',
            icon: LucideIcons.bellRing,
            backgroundColor: const Color(0xFFF54900),
            onPressed: () {},
          ),
          const SizedBox(height: 12),
          _buildFullWidthButton(
            text: 'Xuất Excel',
            icon: LucideIcons.sheet,
            backgroundColor: const Color(0xFF155DFC),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  // [MỚI] Widget xếp chồng chữ dọc
  Widget _buildStackedStatusChip(
    String line1,
    String line2,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8), // Bo góc mềm mại
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao vừa đủ nội dung
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            line1,
            style: GoogleFonts.roboto(
              fontSize: 9, // Font nhỏ
              height: 1.0, // Dòng khít nhau
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            line2,
            style: GoogleFonts.roboto(
              fontSize: 9, // Font nhỏ
              height: 1.0, // Dòng khít nhau
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String count,
    required Color countColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: iconColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: countColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? backgroundColor,
    bool isOutlined = false,
  }) {
    final ButtonStyle style = isOutlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: Colors.grey.shade300),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            foregroundColor: const Color(0xFF374151),
            backgroundColor: Colors.white,
          )
        : ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: 20),
              label: Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              style: style,
              icon: Icon(icon, size: 20),
              label: Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
    );
  }
}
