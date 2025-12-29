import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/duty_list_item.dart';
import '../widgets/event_card_item.dart';
import '../widgets/unpaid_student_item.dart';

import '../../../auth/data/repositories/auth_repository.dart';

class OwnerDashboardContent extends ConsumerWidget {
  const OwnerDashboardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu Dashboard
    final statsAsync = ref.watch(statsProvider);
    final dutiesAsync = ref.watch(dutiesProvider);
    final eventsAsync = ref.watch(eventsProvider);

    // 2. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Lớp trưởng";

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Đổi Header thành "Xin chào" giống Student
          Text(
            "Xin chào, $fullName!",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // Subtext đổi lại chút cho hợp ngữ cảnh quản lý
          Text(
            "Đây là tổng quan lớp học của bạn",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),

          const SizedBox(height: 16),

          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi: $err'),
            data: (stats) => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.25,
              ),
              itemCount: stats.length,
              itemBuilder: (context, index) {
                final item = stats[index];
                IconData iconData = LucideIcons.box;
                if (item.iconCode == 1) iconData = LucideIcons.users;
                if (item.iconCode == 2) iconData = LucideIcons.calendar;
                if (item.iconCode == 3) iconData = LucideIcons.dollarSign;
                return StatCard(
                  title: item.title,
                  value: item.value,
                  subValue: item.subValue,
                  color: Color(item.color),
                  icon: iconData,
                );
              },
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Nhiệm vụ trực nhật"),
          dutiesAsync.when(
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
            data: (duties) => Column(
              children: duties.map((d) => DutyListItem(data: d)).toList(),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionTitle("Sự kiện đang mở"),
          eventsAsync.when(
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
            data: (events) => Column(
              children: events.map((e) => EventCardItem(data: e)).toList(),
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Sinh viên chưa nộp quỹ"),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "3 người",
                  style: GoogleFonts.roboto(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const UnpaidStudentItem(
            name: "Nguyễn Văn A",
            desc: "Quỹ lớp HK1",
            amount: "100.000đ",
          ),
          const UnpaidStudentItem(
            name: "Trần Thị B",
            desc: "Quỹ lớp HK1",
            amount: "100.000đ",
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
