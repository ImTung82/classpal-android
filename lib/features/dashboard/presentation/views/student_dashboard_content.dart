import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/task_gradient_card.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/group_member_item.dart';

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

    // 2. Lấy danh sách nhiệm vụ (Đã cập nhật trả về List<StudentTaskData>)
    final taskAsync = ref.watch(studentTaskProvider(classId));

    // 3. Lấy danh sách tổ để tìm teamId của User hiện tại
    final groupsAsync = ref.watch(teamGroupsProvider(classId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentTaskProvider(classId));
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

            // [FIX] HIỂN THỊ DANH SÁCH NHIỆM VỤ (HIỆN ĐẦY ĐỦ 4 CÁI)
            taskAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, s) => Text("Lỗi tải nhiệm vụ: $e"),
              data: (tasks) {
                if (tasks.isEmpty) {
                  return _buildEmptyTaskCard();
                }
                // Duyệt qua danh sách để hiện toàn bộ card nhiệm vụ
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

            // CÁC THẺ HÀNH ĐỘNG NHANH
            DashboardActionCard(
              title: "Sự kiện mới",
              description: "Hội thảo Khởi nghiệp 2024",
              buttonText: "Đăng ký ngay",
              icon: LucideIcons.calendar,
              iconBgColor: const Color(0xFFF3E8FF),
              iconColor: const Color(0xFF9333EA),
              buttonColor: const Color(0xFFA855F7),
              onTap: () {},
            ),
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

            const SizedBox(height: 16),

            // [FIX] PHẦN HIỂN THỊ ĐỒNG ĐỘI (CÓ LOGIC TỔ TRƯỞNG)
            groupsAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Không thể tải thông tin tổ"),
              data: (groups) {
                final myTeamList = groups
                    .where((g) => g.members.any((m) => m.userId == user?.id))
                    .toList();

                if (myTeamList.isEmpty) return const SizedBox();

                final myTeam = myTeamList.first;

                // Watch provider groupMembers để lấy danh sách kèm isLeader
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
                      Text(
                        "Tổ của bạn (${myTeam.name})",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      membersDetailedAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, s) => const Text("Lỗi tải thành viên"),
                        data: (membersDetailed) {
                          // Sắp xếp tổ trưởng lên đầu danh sách hiển thị
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
