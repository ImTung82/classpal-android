import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/duty_view_model.dart';
import '../widgets/student_duty_card.dart';
import '../widgets/upcoming_duty_item.dart';
import '../widgets/score_board_item.dart';
import '../../../teams/presentation/widgets/team_member_item.dart';

class StudentDutyContent extends ConsumerStatefulWidget {
  final String classId;

  const StudentDutyContent({super.key, required this.classId});

  @override
  ConsumerState<StudentDutyContent> createState() => _StudentDutyContentState();
}

class _StudentDutyContentState extends ConsumerState<StudentDutyContent> {
  // Trạng thái mở rộng danh sách nhiệm vụ của tôi
  bool _isMyDutyExpanded = false;
  // Trạng thái mở rộng danh sách tuần sau
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final scoresAsync = ref.watch(scoreBoardProvider(widget.classId));
    final myDutyAsync = ref.watch(myDutyProvider(widget.classId));
    final upcomingAsync = ref.watch(upcomingDutiesProvider(widget.classId));
    final teamMembersAsync = ref.watch(myTeamMembersProvider(widget.classId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(scoreBoardProvider(widget.classId));
        ref.invalidate(myDutyProvider(widget.classId));
        ref.invalidate(upcomingDutiesProvider(widget.classId));
        ref.invalidate(myTeamMembersProvider(widget.classId));
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
            const SizedBox(height: 16),

            // ---  Hiển thị danh sách nhiệm vụ tuần này ---
            myDutyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text('Lỗi tải dữ liệu: $e'),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return _buildNoDutyCard();
                }

                final displayTasks = _isMyDutyExpanded
                    ? tasks
                    : tasks.take(2).toList();

                return Column(
                  children: [
                    ...displayTasks
                        .map(
                          (task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: StudentDutyCard(
                              task: task,
                              classId: widget.classId,
                            ),
                          ),
                        )
                        .toList(),

                    // Nút Xem thêm / Thu gọn cho Nhiệm vụ của bạn
                    if (tasks.length > 2)
                      GestureDetector(
                        onTap: () => setState(
                          () => _isMyDutyExpanded = !_isMyDutyExpanded,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isMyDutyExpanded
                                    ? "Thu gọn"
                                    : "Xem thêm nhiệm vụ (${tasks.length - 2})",
                                style: GoogleFonts.roboto(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Icon(
                                _isMyDutyExpanded
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: Colors.blue.shade700,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),

            const SizedBox(height: 24),

            // --- Bảng Vàng Thi Đua ---
            _buildSection(
              title: "Bảng Vàng Thi Đua",
              icon: LucideIcons.trophy,
              child: scoresAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Lỗi: $e'),
                data: (scores) => Column(
                  children: scores
                      .map((s) => ScoreBoardItem(score: s))
                      .toList(),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- Danh sách thành viên trong tổ ---
            _buildSection(
              title: "Thành viên tổ của bạn",
              icon: LucideIcons.users,
              child: teamMembersAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => const Text("Lỗi tải thành viên"),
                data: (members) => members.isEmpty
                    ? const Text("Chưa phân vào tổ")
                    : Column(
                        children: members
                            .map(
                              (m) =>
                                  TeamMemberItem(member: m, isEditable: false),
                            )
                            .toList(),
                      ),
              ),
            ),

            const SizedBox(height: 24),

            // --- LỊCH TRỰC TUẦN SAU (Có chức năng Xem thêm) ---
            Text(
              "Lịch trực tuần sau",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: upcomingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => const SizedBox(),
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return const Center(child: Text("Chưa có lịch mới"));
                  }

                  // Quyết định số lượng item hiển thị
                  final displayTasks = _isExpanded
                      ? tasks
                      : tasks.take(5).toList();

                  return Column(
                    children: [
                      ...displayTasks
                          .map((t) => UpcomingDutyItem(task: t))
                          .toList(),

                      // Chỉ hiện nút mũi tên nếu danh sách > 5
                      if (tasks.length > 5)
                        GestureDetector(
                          onTap: () =>
                              setState(() => _isExpanded = !_isExpanded),
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _isExpanded
                                      ? "Thu gọn"
                                      : "Xem thêm (${tasks.length - 5})",
                                  style: GoogleFonts.roboto(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Icon(
                                  _isExpanded
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.blue.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Widget dùng chung cho các khối Section (Bảng vàng, Thành viên)
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFD97706), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
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
