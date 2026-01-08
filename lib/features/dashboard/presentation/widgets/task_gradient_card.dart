import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../../../duties/presentation/view_models/duty_view_model.dart';

class TaskGradientCard extends ConsumerWidget {
  final StudentTaskData data;
  final String classId;

  const TaskGradientCard({
    super.key,
    required this.data,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(dutyControllerProvider).isLoading;
    // Kiểm tra quyền tổ trưởng
    final isLeader = ref.watch(isLeaderProvider(classId)).value ?? false;

    // Tách tiêu đề chính và phụ bằng dấu ":"
    final List<String> titleParts = data.title.split(':');
    final String mainTitle = titleParts[0].trim();
    final String subTitle = titleParts.length > 1 ? titleParts[1].trim() : "";

    // Trạng thái nhiệm vụ
    final bool isDone = data.status == 'Done';
    final bool isActive = data.status == 'Active';

    // --- CẬP NHẬT LOGIC MÀU SẮC ---
    // Hoàn thành: Xanh lá | Đang chờ/Chưa xong: Vàng hổ phách (Amber)
    final Color themeColor = isDone
        ? const Color(0xFF22C55E)
        : const Color(0xFFF59E0B); // Màu vàng Amber cho trạng thái Active

    final Color bgColor = isDone
        ? const Color(0xFFF0FFF4)
        : const Color(0xFFFFFBEB); // Nền vàng nhạt cho trạng thái Active

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
              // Icon Trực nhật - Cố định clipboardList
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  LucideIcons.clipboardList,
                  color: themeColor, // Sẽ là màu vàng nếu chưa xong
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
                            mainTitle,
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
                          data.dateRange,
                          style: GoogleFonts.roboto(
                            color: Colors.grey.shade500,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    if (subTitle.isNotEmpty)
                      Text(
                        subTitle,
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

          // Logic hiển thị Action: Chỉ Tổ trưởng thấy nút bấm xanh khi Active
          if (isLeader && isActive)
            _buildLeaderButton(context, ref, isLoading)
          else
            _buildStatusLabel(isDone, isActive),
        ],
      ),
    );
  }

  // Nút bấm xác nhận dành riêng cho Tổ trưởng (Giữ nguyên CSS xanh dương cho nút hành động)
  Widget _buildLeaderButton(
    BuildContext context,
    WidgetRef ref,
    bool isLoading,
  ) {
    return SizedBox(
      width: double.infinity,
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
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14),
          
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFF3B82F6,
          ), // Nút hành động vẫn giữ màu xanh để nổi bật
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Nhãn trạng thái (Sẽ đổi sang màu vàng nếu đang Active/Chờ xác nhận)
  Widget _buildStatusLabel(bool isDone, bool isActive) {
    String text = "Nhiệm vụ sắp tới";
    IconData icon = LucideIcons.calendarDays;
    Color color = const Color(0xFF64748B);
    Color bg = const Color(0xFFF1F5F9);

    if (isDone) {
      text = "Nhiệm vụ đã hoàn thành";
      icon = LucideIcons.checkCircle;
      color = const Color(0xFF2E7D32); // Xanh lá
      bg = const Color(0xFFE8F5E9);
    } else if (isActive) {
      text = "Đang chờ Tổ trưởng xác nhận...";
      icon = LucideIcons.alertCircle; // Icon cảnh báo
      color = const Color(0xFFB45309); // Vàng đậm (Dark Amber)
      bg = const Color(0xFFFFFBEB); // Vàng nhạt
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.roboto(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _markCompleted(BuildContext context, WidgetRef ref) {
    ref
        .read(dutyControllerProvider.notifier)
        .markAsCompleted(
          classId: classId,
          dutyId: data.id,
          onSuccess: () {
            ref.invalidate(studentTaskProvider(classId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Đã xác nhận hoàn thành!"),
                backgroundColor: Colors.green,
              ),
            );
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
            );
          },
        );
  }
}
