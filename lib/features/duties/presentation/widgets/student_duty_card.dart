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
    // Theo dõi trạng thái loading của controller
    final isLoading = ref.watch(dutyControllerProvider).isLoading;
    // Kiểm tra quyền (Tổ trưởng hoặc Owner) từ Provider đã sửa logic ở bước trước
    final isLeader = ref.watch(isLeaderProvider(classId)).value ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCardColors(task.status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getCardColors(task.status).first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.dateRange,
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(task.status),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            task.description,
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          // Khu vực hiển thị nút bấm hoặc nhãn trạng thái dựa trên phân quyền
          SizedBox(
            width: double.infinity,
            child: _buildActionButton(context, ref, isLeader, isLoading),
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
  ) {
    // 1. Nếu đã hoàn thành
    if (task.status == 'Done') {
      return _buildStatusLabel("✅ Nhiệm vụ đã hoàn thành");
    }

    // 2. Nếu đã quá hạn
    if (task.status == 'Missed') {
      return _buildStatusLabel("❌ Không hoàn thành (Bị trừ 5đ)");
    }

    // 3. Nếu là Tổ trưởng và nhiệm vụ đang diễn ra (Active)
    if (isLeader && task.status == 'Active') {
      return ElevatedButton(
        onPressed: isLoading ? null : () => _markCompleted(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF3B82F6),
          padding: const EdgeInsets.symmetric(vertical: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3B82F6),
                ),
              )
            : Text(
                "Xác nhận hoàn thành (Tổ trưởng)",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
      );
    }

    // 4. Nếu là Sinh viên thường hoặc nhiệm vụ sắp tới (Upcoming)
    // Sinh viên thường không nhìn thấy nút, chỉ thấy dòng trạng thái
    return _buildStatusLabel(
      task.status == 'Active'
          ? "Đang chờ Tổ trưởng xác nhận..."
          : "Nhiệm vụ tuần sau",
    );
  }

  // Nhãn hiển thị trạng thái (dành cho sinh viên thường hoặc task đã xong)
  Widget _buildStatusLabel(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  void _markCompleted(BuildContext context, WidgetRef ref) {
    ref
        .read(dutyControllerProvider.notifier)
        .markAsCompleted(
          classId: classId,
          dutyId: task.id,
          onSuccess: () {
            // Thông báo thành công
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
            // Thông báo lỗi
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

  List<Color> _getCardColors(String status) {
    switch (status) {
      case 'Done':
        return [const Color(0xFF10B981), const Color(0xFF059669)]; // Xanh lá
      case 'Missed':
        return [const Color(0xFFEF4444), const Color(0xFFB91C1C)]; // Đỏ
      case 'Active':
        return [
          const Color(0xFF3B82F6),
          const Color(0xFF2563EB),
        ]; // Xanh dương đậm
      default:
        return [
          const Color(0xFF6366F1),
          const Color(0xFF4F46E5),
        ]; // Tím xanh (Upcoming)
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'Done':
        return LucideIcons.checkCircle;
      case 'Missed':
        return LucideIcons.alertCircle;
      case 'Active':
        return LucideIcons.clock;
      default:
        return LucideIcons.calendar;
    }
  }
}
