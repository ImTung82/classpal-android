import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/task_gradient_card.dart';
import '../widgets/group_member_item.dart';

// Import thêm view model của Quỹ và Tổ để lấy dữ liệu thật
import '../../../funds/presentation/view_models/fund_view_model.dart';
import '../../../teams/presentation/view_models/team_view_model.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../core/utils/currency_utils.dart';

class StudentDashboardContent extends ConsumerWidget {
  final String classId;

  const StudentDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy thông tin User hiện tại
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    final String fullName = user?.userMetadata?['full_name'] ?? "Bạn";

    // 2. Lấy danh sách dữ liệu Dashboard
    final taskAsync = ref.watch(studentTaskProvider(classId));
    final eventsAsync = ref.watch(eventsProvider(classId));

    // 3. Lấy dữ liệu Quỹ thực tế
    final summaryAsync = ref.watch(fundSummaryProvider(classId));
    final campaignsAsync = ref.watch(fundCampaignsProvider(classId));

    // 4. Lấy danh sách tổ
    final groupsAsync = ref.watch(teamGroupsProvider(classId));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(studentTaskProvider(classId));
        ref.invalidate(eventsProvider(classId));
        ref.invalidate(teamGroupsProvider(classId));
        ref.invalidate(fundSummaryProvider(classId));
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
              "Đây là nhiệm vụ của bạn tuần này",
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // I. DANH SÁCH NHIỆM VỤ TRỰC NHẬT
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

            // II. THÔNG BÁO QUỸ LỚP
            summaryAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => const SizedBox(),
              data: (summary) => campaignsAsync.when(
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
                data: (campaigns) {
                  int totalPending = 0;
                  for (var cp in campaigns) {
                    totalPending += (cp.amountPerPerson ?? 0).toInt();
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: totalPending > 0
                          ? const Color(0xFFFFF5F5)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: totalPending > 0
                            ? const Color(0xFFFED7D7)
                            : const Color(0xFFDCFCE7),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.wallet,
                            color: totalPending > 0
                                ? const Color(0xFFE53E3E)
                                : Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Quỹ lớp: ${CurrencyUtils.format(summary.balance)}",
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: const Color(0xFF101727),
                                ),
                              ),
                              if (totalPending > 0)
                                Text(
                                  "Bạn còn thiếu: ${CurrencyUtils.format(totalPending)}",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFFE53E3E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // III. SỰ KIỆN ĐANG DIỄN RA
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
                  children: events
                      .map((event) => _buildEnhancedEventCard(event))
                      .toList(),
                );
              },
            ),

            const SizedBox(height: 24),

            // IV. PHẦN HIỂN THỊ ĐỒNG ĐỘI
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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

  // Widget con hỗ trợ tạo thẻ sự kiện đồng bộ với Quỹ lớp
  Widget _buildEnhancedEventCard(EventData event) {
    double progress = event.total > 0 ? event.current / event.total : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon to tương đương Quỹ lớp
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  LucideIcons.calendarDays,
                  color: Color(0xFF3B82F6),
                  size: 24, // Size to 24 tương đương icon Wallet
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            style: GoogleFonts.roboto(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Trạng thái tag
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: event.isOpen
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            event.isOpen ? "Đang mở" : "Đã đóng",
                            style: TextStyle(
                              color: event.isOpen
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Ngày: ${event.date}",
                      style: GoogleFonts.roboto(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Thanh tiến trình và Text nằm trên cùng 1 hàng ngang
          Row(
            children: [
              Expanded(
                flex: 7,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: const Color(0xFFF1F5F9),
                    color: const Color(0xFF3B82F6),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text(
                  "${event.current}/${event.total} Sinh viên",
                  textAlign: TextAlign.right,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
