import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/event_models.dart';
import '../view_models/event_view_model.dart';
import 'unregister_event_dialog.dart';

class StudentEventCard extends ConsumerWidget {
  final ClassEvent event;
  final String classId;

  const StudentEventCard({
    super.key,
    required this.event,
    required this.classId,
  });

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
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isRegistered = event.participants.any((s) => s.id == currentUserId);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          // HEADER
          Row(
            children: [
              Expanded(
                child: Text(
                  event.title,
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

          Text(
            event.description,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: const Color(0xFF4B5563),
              height: 1.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          _buildInfoRow(LucideIcons.calendar, event.dateDisplay),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.clock, event.timeDisplay),
          const SizedBox(height: 8),
          _buildInfoRow(LucideIcons.mapPin, event.location),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                LucideIcons.timer,
                size: 16,
                color: event.isOpen ? const Color(0xFFF59E0B) : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.isOpen
                      ? "Hạn đăng ký: ${event.deadlineDisplay}"
                      : "Đã hết hạn đăng ký",
                  style: GoogleFonts.roboto(
                    fontSize: 13,
                    color: event.isOpen ? const Color(0xFFB45309) : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ACTION SECTION: Xử lý Logic ở đây
          _buildActionSection(context, ref, isRegistered),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildActionSection(
    BuildContext context,
    WidgetRef ref,
    bool isRegistered,
  ) {
    // 1. ĐÃ ĐĂNG KÝ
    if (isRegistered) {
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
          if (event.isOpen) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: () async {
                  // Hiển thị Dialog Hủy đăng ký
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        UnregisterEventDialog(eventName: event.title),
                  );

                  if (confirm == true && context.mounted) {
                    ref
                        .read(studentEventControllerProvider.notifier)
                        .leaveEvent(
                          classId: classId,
                          eventId: event.id,
                          onSuccess: () => _showSnackbar(
                            context,
                            "Đã hủy đăng ký thành công",
                            Colors.orange,
                          ),
                          onError: (e) =>
                              _showSnackbar(context, "Lỗi: $e", Colors.red),
                        );
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFEF4444),
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
        ],
      );
    }

    // 2. CHƯA ĐĂNG KÝ
    if (!event.isOpen) {
      return SizedBox(
        width: double.infinity,
        height: 44,
        child: ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          child: Text(
            'Đã đóng đăng ký',
            style: GoogleFonts.roboto(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Nút Đăng ký
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: () {
          ref
              .read(studentEventControllerProvider.notifier)
              .joinEvent(
                classId: classId,
                eventId: event.id,
                onSuccess: () =>
                    _showSnackbar(context, "Đăng ký thành công!", Colors.green),
                onError: (e) => _showSnackbar(context, "Lỗi: $e", Colors.red),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF407CFF),
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
