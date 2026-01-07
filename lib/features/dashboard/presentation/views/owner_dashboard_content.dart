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
  final String classId; // [MỚI] Nhận classId để truy vấn dữ liệu chính xác

  const OwnerDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu Dashboard thông qua Family Providers
    final statsAsync = ref.watch(statsProvider(classId));
    final dutiesAsync = ref.watch(dutiesProvider(classId));
    final eventsAsync = ref.watch(eventsProvider(classId));

    // 2. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Lớp trưởng";

    return RefreshIndicator(
      // [MỚI] Thêm tính năng kéo để làm mới dữ liệu
      onRefresh: () async {
        ref.invalidate(statsProvider(classId));
        ref.invalidate(dutiesProvider(classId));
        ref.invalidate(eventsProvider(classId));
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
              "Đây là tổng quan lớp học của bạn",
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // THỐNG KÊ (Sinh viên, Đội nhóm, Sự kiện, Quỹ)
            statsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) =>
                  Center(child: Text('Lỗi tải thống kê: $err')),
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
                  // Logic gán Icon dựa trên iconCode từ Repository
                  IconData iconData = LucideIcons.box;
                  if (item.iconCode == 1)
                    iconData = LucideIcons.users; // Sinh viên
                  if (item.iconCode == 2)
                    iconData = LucideIcons.userPlus; // Đội nhóm
                  if (item.iconCode == 3)
                    iconData = LucideIcons.calendar; // Sự kiện
                  if (item.iconCode == 4)
                    iconData = LucideIcons.dollarSign; // Quỹ lớp

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
              error: (e, s) => Text("Không thể tải nhiệm vụ"),
              data: (duties) => duties.isEmpty
                  ? const Text(
                      "Chưa có lịch trực nhật",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      children: duties
                          .map((d) => DutyListItem(data: d))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle("Sự kiện đang mở"),
            eventsAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => Text("Không thể tải sự kiện"),
              data: (events) => events.isEmpty
                  ? const Text(
                      "Không có sự kiện nào sắp tới",
                      style: TextStyle(color: Colors.grey),
                    )
                  : Column(
                      children: events
                          .map((e) => EventCardItem(data: e))
                          .toList(),
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
                    "Dữ liệu mẫu",
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
            // Hiện tại phần này vẫn dùng dữ liệu mẫu (Hardcode)
            // Bạn có thể phát triển thêm fundProvider trong tương lai
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
