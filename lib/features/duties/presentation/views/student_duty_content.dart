import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/duty_view_model.dart';
import '../../../dashboard/presentation/view_models/dashboard_view_model.dart';
import '../widgets/student_duty_card.dart';
import '../widgets/upcoming_duty_item.dart';
import '../../../dashboard/presentation/widgets/group_member_item.dart';

class StudentDutyContent extends ConsumerWidget {
  final String classId;

  const StudentDutyContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch các provider để lấy dữ liệu
    final myDutyAsync = ref.watch(myDutyProvider(classId));
    final upcomingAsync = ref.watch(upcomingDutiesProvider(classId));
    final membersAsync = ref.watch(groupMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Phần tiêu đề ---
          Text(
            "Nhiệm vụ của bạn",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Lịch trực và nhiệm vụ được giao",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // --- Hiển thị Card nhiệm vụ hiện tại ---
          myDutyAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (e, s) => Center(child: Text('Lỗi tải dữ liệu: $e')),
            data: (task) => task != null
                ? StudentDutyCard(task: task, classId: classId)
                : _buildNoDutyCard(),
          ),

          const SizedBox(height: 24),

          // --- Danh sách thành viên trong tổ (Tên tổ lấy động từ myDutyAsync) ---
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị tên tổ động dựa trên dữ liệu nhiệm vụ
                Text(
                  myDutyAsync.maybeWhen(
                    data: (task) => task != null
                        ? "Thành viên ${task.assignedTo}"
                        : "Thành viên tổ của bạn",
                    orElse: () => "Thành viên tổ",
                  ),
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                membersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  ),
                  error: (e, s) =>
                      const Text("Không thể tải danh sách thành viên"),
                  data: (members) => members.isEmpty
                      ? const Text("Chưa có thành viên nào trong tổ")
                      : Column(
                          children: members
                              .map((m) => GroupMemberItem(member: m))
                              .toList(),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- Lịch sắp tới của lớp (Bắt đầu từ ngày mai) ---
          Text(
            "Lịch sắp tới",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: upcomingAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(),
              data: (tasks) => tasks.isEmpty
                  ? const Center(child: Text("Chưa có lịch trực nhật mới"))
                  : Column(
                      children: tasks
                          .map((t) => UpcomingDutyItem(task: t))
                          .toList(),
                    ),
            ),
          ),

          const SizedBox(
            height: 80,
          ), // Khoảng trống tránh bị Bottom Nav che mất
        ],
      ),
    );
  }

  // Widget hiển thị khi học sinh không có nhiệm vụ trực nhật
  Widget _buildNoDutyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        children: [
          // Đã sửa tên Icon từ Icons.CheckCircleOutline thành Icons.check_circle_outline
          const Icon(Icons.check_circle_outline, color: Colors.blue, size: 48),
          const SizedBox(height: 12),
          Text(
            "Tuyệt vời!",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Bạn không có nhiệm vụ trực nhật trong hôm nay.",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}
