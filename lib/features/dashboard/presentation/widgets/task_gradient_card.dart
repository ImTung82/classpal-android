import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../../../duties/presentation/view_models/duty_view_model.dart';

class TaskGradientCard extends ConsumerWidget {
  final StudentTaskData data;
  final String classId; // Nhận classId để xử lý logic xác nhận

  const TaskGradientCard({
    super.key,
    required this.data,
    required this.classId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Theo dõi trạng thái loading của controller
    final isLoading = ref.watch(dutyControllerProvider).isLoading;
    
    // 2. Kiểm tra quyền (Tổ trưởng hoặc Owner) từ Provider
    final isLeader = ref.watch(isLeaderProvider(classId)).value ?? false;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: _getCardColors(data.status),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: _getCardColors(data.status).first.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.dateRange,
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getStatusIcon(data.status),
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data.title, // Hiển thị đầy đủ: "Tổ 1: Đổ rác và Lau bảng"
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
    if (data.status == 'Done') {
      return _buildStatusLabel("✅ Nhiệm vụ đã hoàn thành");
    }

    // 2. Nếu đã quá hạn (Missed)
    if (data.status == 'Missed') {
      return _buildStatusLabel("❌ Không hoàn thành");
    }

    // 3. Nếu là Tổ trưởng và nhiệm vụ đang diễn ra (Active)
    if (isLeader && data.status == 'Active') {
      return ElevatedButton(
        onPressed: isLoading ? null : () => _markCompleted(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: _getCardColors(data.status).first,
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
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                "Xác nhận hoàn thành (Tổ trưởng)",
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
      );
    }

    // 4. Nếu là Sinh viên thường hoặc nhiệm vụ sắp tới
    return _buildStatusLabel(
      data.status == 'Active'
          ? "Đang chờ Tổ trưởng xác nhận..."
          : "Nhiệm vụ sắp tới",
    );
  }

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
    ref.read(dutyControllerProvider.notifier).markAsCompleted(
          classId: classId,
          dutyId: data.id, // Sử dụng ID thật từ database
          onSuccess: () {
            // Refresh lại dữ liệu Dashboard sau khi hoàn thành
            ref.invalidate(studentTaskProvider(classId));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Đã xác nhận hoàn thành!"), backgroundColor: Colors.green),
            );
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
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
        return [const Color(0xFF3B82F6), const Color(0xFF2563EB)]; // Xanh dương
      default:
        return [const Color(0xFF6366F1), const Color(0xFF9333EA)]; // Tím mặc định
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