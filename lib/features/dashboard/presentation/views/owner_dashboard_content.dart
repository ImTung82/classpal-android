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

// Import thêm ViewModels và Utils của Quỹ lớp
import '../../../funds/presentation/view_models/fund_view_model.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class OwnerDashboardContent extends ConsumerWidget {
  final String classId;

  const OwnerDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy dữ liệu Dashboard chính
    final statsAsync = ref.watch(statsProvider(classId));
    final dutiesAsync = ref.watch(dutiesProvider(classId));
    final eventsAsync = ref.watch(eventsProvider(classId));

    // 2. [QUAN TRỌNG] Lấy dữ liệu Quỹ lớp thật
    final campaignsAsync = ref.watch(fundCampaignsProvider(classId));

    // 3. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Lớp trưởng";

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statsProvider(classId));
        ref.invalidate(dutiesProvider(classId));
        ref.invalidate(eventsProvider(classId));
        ref.invalidate(fundCampaignsProvider(classId));
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

            // I. THỐNG KÊ (Sinh viên, Đội nhóm, Sự kiện, Quỹ)
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
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
                  IconData iconData = LucideIcons.box;
                  if (item.iconCode == 1) iconData = LucideIcons.users;
                  if (item.iconCode == 2) iconData = LucideIcons.userPlus;
                  if (item.iconCode == 3) iconData = LucideIcons.calendar;
                  if (item.iconCode == 4) iconData = LucideIcons.dollarSign;

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

            // II. NHIỆM VỤ TRỰC NHẬT
            _buildSectionTitle("Nhiệm vụ trực nhật"),
            dutiesAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Không thể tải nhiệm vụ"),
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

            // III. SỰ KIỆN ĐANG MỞ
            _buildSectionTitle("Sự kiện đang mở"),
            eventsAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Không thể tải sự kiện"),
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

            // IV. [FIX] SINH VIÊN CHƯA NỘP QUỸ (DỮ LIỆU THẬT)
            _buildSectionTitle("Sinh viên chưa nộp quỹ"),
            const SizedBox(height: 4),

            campaignsAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => Text("Lỗi tải quỹ: $e"),
              data: (campaigns) {
                if (campaigns.isEmpty) {
                  return const Text(
                    "Không có khoản thu nào đang mở",
                    style: TextStyle(color: Colors.grey),
                  );
                }

                // Lấy chiến dịch (Campaign) mới nhất để hiển thị danh sách chưa nộp
                final latestCampaign = campaigns.first;

                // Lắng nghe danh sách chưa nộp của campaign này
                final unpaidAsync = ref.watch(
                  fundUnpaidProvider((
                    classId: classId,
                    campaignId: latestCampaign.id,
                  )),
                );

                return unpaidAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, s) => const SizedBox(),
                  data: (members) {
                    final unpaidList = members
                        .where((m) => !m.isPaid)
                        .take(5)
                        .toList();

                    if (unpaidList.isEmpty) {
                      return const Text(
                        "Tuyệt vời! Cả lớp đã nộp đủ quỹ.",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            "Chiến dịch: ${latestCampaign.title}",
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ...unpaidList.map(
                          (m) => UnpaidStudentItem(
                            name: m.fullName,
                            desc: "Mã SV: ${m.studentCode}",
                            amount: CurrencyUtils.format(
                              latestCampaign.amountPerPerson,
                            ),
                          ),
                        ),
                        if (members.where((m) => !m.isPaid).length > 5)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              "Và ${members.where((m) => !m.isPaid).length - 5} sinh viên khác chưa nộp...",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
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
