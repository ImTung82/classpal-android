import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/task_gradient_card.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/group_member_item.dart';
import '../widgets/event_card_item.dart'; // [MỚI] Đảm bảo đã import widget này

import '../../../teams/presentation/view_models/team_view_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class StudentDashboardContent extends ConsumerWidget {
  final String classId;

  const StudentDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Bạn";

    // 2. Lấy danh sách dữ liệu (Nhiệm vụ, Sự kiện)
    final taskAsync = ref.watch(studentTaskProvider(classId));
    final eventsAsync = ref.watch(
      eventsProvider(classId),
    ); // [MỚI] Gọi provider sự kiện thực tế

    // 3. Lấy danh sách tổ để tìm teamId
    final groupsAsync = ref.watch(teamGroupsProvider(classId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentTaskProvider(classId));
        ref.invalidate(
          eventsProvider(classId),
        ); // [MỚI] Reset sự kiện khi vuốt xuống
        ref.invalidate(teamGroupsProvider(classId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin chào, $fullName!",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Đây là nhiệm vụ của bạn tuần này",
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // I. HIỂN THỊ DANH SÁCH NHIỆM VỤ TRỰC NHẬT
            taskAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Text("Lỗi tải nhiệm vụ: $e"),
              data: (tasks) {
                if (tasks.isEmpty) return _buildEmptyTaskCard();
                return Column(
                  children: tasks
                      .map(
                        (task) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskGradientCard(data: task, classId: classId),
                        ),
                      )
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // II. CÁC THẺ HÀNH ĐỘNG NHANH
            DashboardActionCard(
              title: "Quỹ lớp",
              description: "Bạn chưa nộp quỹ HK1",
              buttonText: "Xem chi tiết",
              icon: LucideIcons.dollarSign,
              iconBgColor: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              buttonColor: const Color(0xFF00C853),
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // III. [FIX] HIỂN THỊ SỰ KIỆN ĐANG DIỄN RA
            _buildSectionTitle("Sự kiện đang diễn ra"),
            const SizedBox(height: 12),
            eventsAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text("Lỗi tải sự kiện: $e"),
              data: (events) {
                if (events.isEmpty) {
                  return const Text(
                    "Không có sự kiện nào sắp tới",
                    style: TextStyle(color: Colors.grey),
                  );
                }
                return Column(
                  children: events.map((e) => EventCardItem(data: e)).toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // IV. PHẦN HIỂN THỊ ĐỒNG ĐỘI (CÓ LOGIC TỔ TRƯỞNG)
            groupsAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Không thể tải thông tin tổ"),
              data: (groups) {
                final myTeamList = groups
                    .where((g) => g.members.any((m) => m.userId == user?.id))
                    .toList();
                if (myTeamList.isEmpty) return const SizedBox();

                final myTeam = myTeamList.first;
                final membersDetailedAsync = ref.watch(
                  groupMembersProvider(myTeam.id),
                );

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
                      _buildSectionTitle("Tổ của bạn (${myTeam.name})"),
                      const SizedBox(height: 12),
                      membersDetailedAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => const Text("Lỗi tải thành viên"),
                        data: (membersDetailed) {
                          final sortedMembers = [...membersDetailed];
                          sortedMembers.sort(
                            (a, b) =>
                                (b.isLeader ? 1 : 0) - (a.isLeader ? 1 : 0),
                          );

                          return Column(
                            children: sortedMembers
                                .map((m) => GroupMemberItem(member: m))
                                .toList(),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- Hàm Helper hiển thị tiêu đề các phần (Giống Lớp trưởng) ---
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontWeight: FontWeight.bold,
        fontSize: 16,
        color: const Color(0xFF101727),
      ),
    );
  }

  Widget _buildEmptyTaskCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Text(
        "Bạn không có nhiệm vụ trực nhật nào trong tuần này.",
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }
}
