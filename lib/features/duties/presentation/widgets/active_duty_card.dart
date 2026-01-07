import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/duty_models.dart';
import '../view_models/duty_view_model.dart';
import 'delete_duty_dialog.dart'; // [IMPORT] File dialog xóa mới tạo

class ActiveDutyCard extends ConsumerWidget {
  final DutyTask task;
  final String classId;

  const ActiveDutyCard({super.key, required this.task, required this.classId});

  void _showSnackbar(BuildContext context, String msg, Color color) {
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
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Title & Delete Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // [NEW] Icon xóa chu kỳ trực nhật
              InkWell(
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => DeleteDutyDialog(dutyTitle: task.title),
                  );

                  if (confirm == true && context.mounted) {
                    ref
                        .read(dutyControllerProvider.notifier)
                        .deleteDutySeries(
                          classId: classId,
                          generalId: task.generalId, // Xóa theo mã chu kỳ
                          onSuccess: () => _showSnackbar(
                            context,
                            "Đã xóa toàn bộ chu kỳ trực nhật",
                            Colors.green,
                          ),
                          onError: (e) =>
                              _showSnackbar(context, "Lỗi: $e", Colors.red),
                        );
                  }
                },
                child: const Icon(
                  LucideIcons.trash2,
                  size: 18,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 2. DESCRIPTION
          Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 12),

          // 3. DATE RANGE
          Text(
            task.dateRange,
            style: GoogleFonts.roboto(color: Colors.grey[500], fontSize: 12),
          ),
          const Spacer(),

          // 4. FOOTER: Assigned To & Reminder Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    task.assignedTo,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(dutyControllerProvider.notifier)
                      .sendReminder(
                        classId: classId,
                        dutyId: task.id,
                        onSuccess: () => _showSnackbar(
                          context,
                          "Đã gửi nhắc nhở tới ${task.assignedTo}",
                          Colors.green,
                        ),
                        onError: (e) => _showSnackbar(context, e, Colors.red),
                      );
                },
                icon: const Icon(LucideIcons.bell, size: 14),
                label: const Text("Nhắc"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
