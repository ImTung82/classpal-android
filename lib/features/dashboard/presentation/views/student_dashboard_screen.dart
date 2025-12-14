import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// Core
import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';

// Models & ViewModel
import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';

// Widgets mới
import '../widgets/task_gradient_card.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/group_member_item.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends ConsumerState<StudentDashboardScreen> {
  int _bottomNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Lắng nghe dữ liệu
    final taskAsync = ref.watch(studentTaskProvider);
    final membersAsync = ref.watch(groupMembersProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      
      // Header: Chú ý subtitle là "Thành viên"
      appBar: AppHeader(
        title: "Lớp Toán K20",
        subtitle: "Thành viên", 
        onMenuPressed: () {},
      ),
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Greeting
            Text("Xin chào, Nguyễn Văn A!", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Đây là nhiệm vụ của bạn tuần này", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 16),

            // 2. Nhiệm vụ (Gradient Card)
            taskAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => const SizedBox(),
              data: (task) => TaskGradientCard(data: task),
            ),
            
            const SizedBox(height: 24),

            // 3. Sự kiện mới
            DashboardActionCard(
              title: "Sự kiện mới",
              description: "Hội thảo Khởi nghiệp 2024",
              buttonText: "Đăng ký ngay",
              icon: LucideIcons.calendar,
              iconBgColor: const Color(0xFFF3E8FF), // Tím nhạt
              iconColor: const Color(0xFF9333EA),   // Tím đậm
              buttonColor: const Color(0xFFA855F7), // Tím nút bấm
              onTap: () {},
            ),

            // 4. Quỹ lớp
            DashboardActionCard(
              title: "Quỹ lớp",
              description: "Bạn chưa nộp quỹ HK1",
              buttonText: "Xem chi tiết",
              icon: LucideIcons.dollarSign,
              iconBgColor: const Color(0xFFDCFCE7), // Xanh nhạt
              iconColor: const Color(0xFF16A34A),   // Xanh đậm
              buttonColor: const Color(0xFF00C853), // Xanh nút bấm
              onTap: () {},
            ),

            const SizedBox(height: 16),

            // 5. Danh sách tổ
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
                  Text("Tổ của bạn (Tổ 3)", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  membersAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, s) => const Text("Lỗi tải danh sách"),
                    data: (members) => Column(
                      children: members.map((m) => GroupMemberItem(member: m)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
      ),
    );
  }
}