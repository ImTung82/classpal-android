import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/repositories/event_repository.dart'; 
import '../../data/models/event_models.dart';
import '../../data/models/event_models.dart';
import '../../data/models/event_models.dart';
import '../view_models/owner_event_view_model.dart';
import 'edit_event_dialog.dart';
import 'delete_event_dialog.dart';
import 'event_details_dialog.dart';
import 'export_event_excel.dart';

class OwnerEventCard extends ConsumerWidget {
  final ClassEvent event;
  final String classId;

  const OwnerEventCard({super.key, required this.event, required this.classId});

  String _getDeadlineStatusText() {
    if (!event.isOpen) return "Đã hết hạn đăng ký";
    final duration = event.timeRemainingToRegister;
    if (duration.inDays > 0) return "Còn ${duration.inDays} ngày đăng ký";
    if (duration.inHours > 0) return "Còn ${duration.inHours} giờ đăng ký";
    return "Sắp hết hạn (< ${duration.inMinutes} phút)";
  }

  Color _getDeadlineColor() {
    if (!event.isOpen) return Colors.red;
    if (event.timeRemainingToRegister.inDays < 1) return Colors.orange;
    return Colors.green;
  }

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
          // 1. HEADER
          Row(
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
              if (event.isMandatory) ...[
                _buildStackedStatusChip(
                  'Bắt',
                  'buộc',
                  const Color(0xFFFFE2E2),
                  const Color(0xFFC10007),
                ),
                const SizedBox(width: 6),
              ],
              _buildStackedStatusChip(
                event.isOpen ? 'Đang' : 'Đã',
                event.isOpen ? 'mở' : 'đóng',
                event.isOpen
                    ? const Color(0xFFDCFCE7)
                    : const Color(0xFFF3F4F6),
                event.isOpen
                    ? const Color(0xFF008235)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              _buildActionIcons(context, ref),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
              Expanded(
                child: _buildInfoRow(LucideIcons.calendar, event.dateDisplay),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoRow(LucideIcons.clock, event.timeDisplay),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow(LucideIcons.mapPin, event.location),
          const SizedBox(height: 12),

          // 2. DEADLINE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _getDeadlineColor().withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getDeadlineColor().withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.timer, size: 16, color: _getDeadlineColor()),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hạn ĐK: ${event.deadlineDisplay}",
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _getDeadlineStatusText(),
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getDeadlineColor(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. PROGRESS & STATS
          _buildProgressBar(),
          const SizedBox(height: 20),
          _buildStatisticCards(),
          const SizedBox(height: 20),

          // 4. ACTION BUTTONS (Dòng này CSS giống demo.dart)
          _buildButton(
            text: 'Xem chi tiết sinh viên',
            icon: LucideIcons.users,
            isOutlined: true,
            onPressed: () => showDialog(
              context: context,
              builder: (context) => EventDetailsDialog(event: event),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  text: 'Gửi nhắc nhở',
                  icon: LucideIcons.bellRing,
                  bgColor: const Color(0xFFF54900),
                  onPressed: () => _showSnackbar(
                    context,
                    "Đã gửi thông báo thành công!",
                    Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  text: 'Xuất Excel',
                  icon: LucideIcons.sheet,
                  bgColor: const Color(0xFF155DFC),
                  onPressed: () async {
                    try {
                      await ExportEventExcel.execute(event);
                      _showSnackbar(
                        context,
                        "Xuất file Excel thành công!",
                        Colors.green,
                      );
                    } catch (e) {
                      _showSnackbar(context, e.toString(), Colors.red);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGET CON ---
  Widget _buildProgressBar() {
    return Row(
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
          style: GoogleFonts.roboto(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatisticCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.check_circle,
            color: const Color(0xFF00A63E),
            bgColor: const Color(0xFFF0FDF4),
            title: "Đã đăng ký",
            count: "${event.registeredCount}",
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatItem(
            icon: Icons.cancel,
            color: const Color(0xFFF54900),
            bgColor: const Color(0xFFFFF7ED),
            title: "Chưa đăng ký",
            count: "${event.unregisteredCount}",
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: GoogleFonts.roboto(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? bgColor,
    bool isOutlined = false,
  }) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: Color(0xFFD0D5DB)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: const Color(0xFF354152),
          )
        : ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: bgColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          );

    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(
                text,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
              ),
              style: style,
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(icon, size: 18),
              label: Text(
                text,
                style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
              ),
              style: style,
            ),
    );
  }

  Widget _buildActionIcons(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        InkWell(
          onTap: () async {
            final res = await showDialog<ClassEvent>(
              context: context,
              builder: (ctx) => EditEventDialog(event: event),
            );
            if (res != null)
              ref
                  .read(eventControllerProvider.notifier)
                  .updateEvent(
                    classId: classId,
                    event: res,
                    onSuccess: () => _showSnackbar(
                      context,
                      "Cập nhật thành công",
                      Colors.green,
                    ),
                    onError: (e) => _showSnackbar(context, e, Colors.red),
                  );
          },
          child: const Icon(LucideIcons.pencil, size: 20, color: Colors.blue),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => DeleteEventDialog(eventName: event.title),
            );
            if (confirm == true)
              ref
                  .read(eventControllerProvider.notifier)
                  .deleteEvent(
                    classId: classId,
                    eventId: event.id,
                    onSuccess: () =>
                        _showSnackbar(context, "Đã xóa", Colors.green),
                    onError: (e) => _showSnackbar(context, e, Colors.red),
                  );
          },
          child: const Icon(LucideIcons.trash2, size: 20, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildStackedStatusChip(String l1, String l2, Color bg, Color txt) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            l1,
            style: GoogleFonts.roboto(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: txt,
            ),
          ),
          Text(
            l2,
            style: GoogleFonts.roboto(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: txt,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF4B5563),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
