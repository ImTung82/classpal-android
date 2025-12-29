import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/task_gradient_card.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/group_member_item.dart';

import '../../../auth/data/repositories/auth_repository.dart';

class StudentDashboardContent extends ConsumerWidget {
  const StudentDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu Dashboard
    final taskAsync = ref.watch(studentTaskProvider);
    final membersAsync = ref.watch(groupMembersProvider);

    // 2. Lấy thông tin User hiện tại từ Auth Repository
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Bạn";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hiển thị tên thật của User
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

          taskAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
            data: (task) => TaskGradientCard(data: task),
          ),

          const SizedBox(height: 24),
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
          Container(
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
                  "Tổ của bạn (Tổ 3)",
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                membersAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const Text("Lỗi tải danh sách"),
                  data: (members) => Column(
                    children: members
                        .map((m) => GroupMemberItem(member: m))
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
