import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/event_models.dart';
import 'edit_event_dialog.dart';
import 'delete_event_dialog.dart';
import 'event_details_dialog.dart';
import '../view_models/owner_event_view_model.dart';

class OwnerEventCard extends ConsumerWidget {
  final ClassEvent event;
  final String classId; // Thêm classId

  const OwnerEventCard({super.key, required this.event, required this.classId});

  void _showSnackbar(BuildContext context, String msg, Color color) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF101727),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // B. Tags
              // Luôn hiển thị trạng thái bắt buộc nếu có
              if (event.isMandatory) ...[
                _buildStackedStatusChip(
                  'Bắt',
                  'buộc',
                  const Color(0xFFFFE2E2),
                  const Color(0xFFC10007),
                ),
                const SizedBox(width: 6),
              ],

              // --- LOGIC HIỂN THỊ TAG TRẠNG THÁI (ĐANG MỞ / ĐÃ ĐÓNG) ---
              if (event.isOpen)
                _buildStackedStatusChip(
                  'Đang',
                  'mở',
                  const Color(0xFFDCFCE7),
                  const Color(0xFF008235),
                )
              else
                _buildStackedStatusChip(
                  'Đã',
                  'đóng',
                  const Color(0xFFF3F4F6), // Màu nền xám nhạt
                  const Color(0xFF6B7280), // Màu chữ xám đậm
                ),

              const SizedBox(width: 12),

              // C. Action Icons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nút Sửa
                  _buildActionButton(LucideIcons.pencil, Colors.blue, () async {
                    final result = await showDialog<ClassEvent>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => EditEventDialog(event: event),
                    );

                    if (result != null && context.mounted) {
                      ref
                          .read(eventControllerProvider.notifier)
                          .updateEvent(
                            classId: classId,
                            event: result,
                            onSuccess: () => _showSnackbar(
                              context,
                              'Cập nhật sự kiện thành công!',
                              Colors.green,
                            ),
                            onError: (e) =>
                                _showSnackbar(context, 'Lỗi: $e', Colors.red),
                          );
                    }
                  }),

                  const SizedBox(width: 4),

                  // Nút Xóa
                  _buildActionButton(LucideIcons.trash2, Colors.red, () async {
                    final confirmDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) =>
                          DeleteEventDialog(eventName: event.title),
                    );

                    if (confirmDelete == true && context.mounted) {
                      ref
                          .read(eventControllerProvider.notifier)
                          .deleteEvent(
                            classId: classId,
                            eventId: event.id,
                            onSuccess: () {
                              _showSnackbar(
                                context,
                                'Xóa sự kiện thành công!',
                                Colors.green,
                              );
                              // Không cần invalidate ở đây nữa, Controller đã làm rồi
                            },
                            onError: (e) {
                              _showSnackbar(context, 'Lỗi: $e', Colors.red);
                            },
                          );
                    }
                  }),
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

          // 3. Date & Time Row (Thẳng hàng ngang)
          Row(
            children: [
              Expanded(child: _buildInfoRow(LucideIcons.calendar, event.date)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoRow(LucideIcons.clock, event.time)),
            ],
          ),

          // 4. Location Row (Địa điểm)
          const SizedBox(height: 12),
          _buildInfoRow(LucideIcons.mapPin, event.location),

          const SizedBox(height: 16),

          // 5. Progress Bar & Ratio
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

          // 6. Statistic Cards
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

          // 7. Action Button
          // Nút Xem chi tiết
          _buildFullWidthButton(
            text: 'Xem chi tiết',
            icon: LucideIcons.users,
            isOutlined: true,
            onPressed: () {
              // Gọi Dialog Xem chi tiết
              showDialog(
                context: context,
                builder: (context) => EventDetailsDialog(event: event),
              );
            },
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
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            line1,
            style: GoogleFonts.roboto(
              fontSize: 9,
              height: 1.0,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            line2,
            style: GoogleFonts.roboto(
              fontSize: 9,
              height: 1.0,
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
      crossAxisAlignment: CrossAxisAlignment.start, // Căn trên cùng
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          // Thay Flexible bằng Expanded để chiếm hết không gian
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
            // Bỏ overflow để text wrap xuống dòng nếu dài
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
