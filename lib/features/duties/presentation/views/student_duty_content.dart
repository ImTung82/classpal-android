import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/duty_view_model.dart';
import '../widgets/student_duty_card.dart';
import '../widgets/upcoming_duty_item.dart';
import '../../../teams/presentation/widgets/team_member_item.dart';

class StudentDutyContent extends ConsumerWidget {
  final String classId;

  const StudentDutyContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy nhiệm vụ hiện tại của cá nhân/tổ
    final myDutyAsync = ref.watch(myDutyProvider(classId));

    // 2. Lấy lịch trực tuần sau (Repository đã lọc lte/gte trong phạm vi 7 ngày tới)
    final upcomingAsync = ref.watch(upcomingDutiesProvider(classId));

    // 3. SỬA LỖI 1: Lấy đúng thành viên trong tổ của mình
    final teamMembersAsync = ref.watch(myTeamMembersProvider(classId));

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

          // --- Hiển thị Card nhiệm vụ tuần này ---
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

          // --- SỬA LỖI 1: Danh sách thành viên trong tổ ---
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
                Text(
                  "Thành viên tổ của bạn",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                teamMembersAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: LinearProgressIndicator(),
                  ),
                  error: (e, s) =>
                      const Text("Không thể tải danh sách thành viên"),
                  data: (members) => members.isEmpty
                      ? const Text("Bạn chưa được phân vào tổ nào")
                      : Column(
                          children: members
                              .map(
                                (m) => TeamMemberItem(
                                  member: m,
                                  isEditable:
                                      false, // Sinh viên không có quyền edit
                                ),
                              )
                              .toList(),
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SỬA LỖI 4: Lịch sắp tới (Chỉ hiện tuần tiếp theo) ---
          Text(
            "Lịch trực tuần sau",
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

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // Widget hiển thị khi học sinh không có nhiệm vụ trực nhật trong tuần này
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
            "Bạn không có nhiệm vụ trực nhật trong tuần này.",
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(color: Colors.blue.shade700),
          ),
        ],
      ),
    );
  }
}
