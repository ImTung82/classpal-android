import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/duty_models.dart';
import '../view_models/duty_view_model.dart';

class StudentDutyCard extends ConsumerWidget {
  final DutyTask task;
  final String classId;

  const StudentDutyCard({super.key, required this.task, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Giữ nguyên logic xử lý dữ liệu
    final isLoading = ref.watch(dutyControllerProvider).isLoading;
    final isLeader = ref.watch(isLeaderProvider(classId)).value ?? false;

    // Thiết lập trạng thái hiển thị
    final bool isDone = task.status == 'Done';
    final bool isActive = task.status == 'Active';
    final bool isMissed = task.status == 'Missed';

    // Xác định màu sắc chủ đạo cho phần giao diện mới (Vàng cho Active, Xanh cho Done, Đỏ cho Missed)
    Color themeColor = const Color(0xFFF59E0B); // Mặc định Vàng (Active)
    Color bgColor = const Color(0xFFFFFBEB);

    if (isDone) {
      themeColor = const Color(0xFF22C55E); // Xanh lá
      bgColor = const Color(0xFFF0FFF4);
    } else if (isMissed) {
      themeColor = const Color(0xFFEF4444); // Đỏ
      bgColor = const Color(0xFFFEF2F2);
    }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Trực nhật - Cố định clipboardList đồng bộ với TaskGradientCard
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.clipboardList,
                  color: themeColor,
                  size: 24,
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
                            task.title,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          task.dateRange,
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
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
          const SizedBox(height: 16),
          // Khu vực hiển thị nút bấm hoặc nhãn trạng thái dựa trên phân quyền (Giữ nguyên logic)
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(
              context,
              ref,
              isLeader,
              isLoading,
              isDone,
              isActive,
              isMissed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    bool isLeader,
    bool isLoading,
    bool isDone,
    bool isActive,
    bool isMissed,
  ) {
    // 1. Nếu đã hoàn thành
    if (isDone) {
      return _buildStatusLabel(
        "Nhiệm vụ đã hoàn thành",
        LucideIcons.checkCircle,
        const Color(0xFF2E7D32),
        const Color(0xFFE8F5E9),
      );
    }

    // 2. Nếu đã quá hạn
    if (isMissed) {
      return _buildStatusLabel(
        "Không hoàn thành (Bị trừ 5đ)",
        LucideIcons.xCircle,
        const Color(0xFFDC2626),
        const Color(0xFFFEF2F2),
      );
    }

    // 3. Nếu là Tổ trưởng và nhiệm vụ đang diễn ra (Active)
    if (isLeader && isActive) {
      return SizedBox(
        height: 44,
        child: ElevatedButton.icon(
          onPressed: isLoading ? null : () => _markCompleted(context, ref),
          icon: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(LucideIcons.checkCircle2, size: 18),
          label: Text(
            "Xác nhận hoàn thành (Tổ trưởng)",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // 4. Nếu là Sinh viên thường hoặc nhiệm vụ sắp tới (Upcoming)
    return _buildStatusLabel(
      isActive ? "Đang chờ Tổ trưởng xác nhận..." : "Nhiệm vụ tuần sau",
      isActive ? LucideIcons.alertCircle : LucideIcons.calendar,
      isActive ? const Color(0xFFB45309) : const Color(0xFF64748B),
      isActive ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9),
    );
  }

  Widget _buildStatusLabel(
    String text,
    IconData icon,
    Color textColor,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Giữ nguyên logic nghiệp vụ xác nhận hoàn thành
  void _markCompleted(BuildContext context, WidgetRef ref) {
    ref
        .read(dutyControllerProvider.notifier)
        .markAsCompleted(
          classId: classId,
          dutyId: task.id,
          onSuccess: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text("Đã xác nhận hoàn thành! +5 điểm cho tổ."),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Lỗi: $e"),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
  }
}
