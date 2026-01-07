import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/duty_view_model.dart';
import '../widgets/student_duty_card.dart';
import '../widgets/upcoming_duty_item.dart';
import '../widgets/score_board_item.dart';
import '../../../teams/presentation/widgets/team_member_item.dart';

class StudentDutyContent extends ConsumerWidget {
  final String classId;

  const StudentDutyContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy bảng điểm thi đua của lớp
    final scoresAsync = ref.watch(scoreBoardProvider(classId));

    // 2. Lấy nhiệm vụ hiện tại của cá nhân/tổ
    final myDutyAsync = ref.watch(myDutyProvider(classId));

    // 3. Lấy lịch trực tuần sau
    final upcomingAsync = ref.watch(upcomingDutiesProvider(classId));

    // 4. Lấy thành viên trong tổ của mình
    final teamMembersAsync = ref.watch(myTeamMembersProvider(classId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(scoreBoardProvider(classId));
        ref.invalidate(myDutyProvider(classId));
        ref.invalidate(upcomingDutiesProvider(classId));
        ref.invalidate(myTeamMembersProvider(classId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
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

            // --- [MỚI] BẢNG VÀNG THI ĐUA ---
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
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.trophy,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Bảng Vàng Thi Đua",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  scoresAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                    error: (e, s) => Text('Lỗi tải bảng điểm: $e'),
                    data: (scores) => scores.isEmpty
                        ? const Center(child: Text("Chưa có bảng điểm"))
                        : Column(
                            children: scores
                                .map((s) => ScoreBoardItem(score: s))
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Danh sách thành viên trong tổ ---
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
                                    isEditable: false,
                                  ),
                                )
                                .toList(),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Lịch trực tuần sau ---
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
      ),
    );
  }

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
