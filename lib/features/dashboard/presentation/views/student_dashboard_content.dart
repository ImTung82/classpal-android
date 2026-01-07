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
  final String classId; // [MỚI] Nhận classId từ màn hình cha

  const StudentDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Bạn";

    // 2. Lấy dữ liệu Dashboard cá nhân
    final taskAsync = ref.watch(studentTaskProvider(classId));

    // 3. Logic lấy danh sách thành viên trong tổ:
    // Đầu tiên cần tìm xem sinh viên này thuộc teamId nào trong class_members
    // Ở đây ta có thể tận dụng teamGroupsProvider đã có để tìm teamId của user hiện tại
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

            // Hiển thị nhiệm vụ trực nhật cá nhân
            taskAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(),
              data: (task) => task != null 
                ? TaskGradientCard(data: task)
                : const Text("Bạn không có nhiệm vụ nào trong tuần này."),
            ),

            const SizedBox(height: 24),
            
            // Các thẻ hành động nhanh
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

            // Phần hiển thị đồng đội (Team Members)
            groupsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, s) => const Text("Không thể tải thông tin tổ"),
              data: (groups) {
                // Tìm tổ mà sinh viên này đang tham gia
                final myTeam = groups.firstWhere(
                  (g) => g.members.any((m) => m.userId == user?.id),
                  orElse: () => throw Exception("Chưa vào tổ"),
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
                      // Hiển thị danh sách thành viên trong tổ đó
                      ...myTeam.members.map((m) => GroupMemberItem(
                        member: GroupMemberData(m.name, m.avatarColor)
                      )).toList(),
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
}