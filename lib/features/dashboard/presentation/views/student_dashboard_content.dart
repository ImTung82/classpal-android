import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart';
import '../widgets/task_gradient_card.dart';
import '../widgets/group_member_item.dart';
import '../widgets/event_card_item.dart';

// Import ViewModels và Utils
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
    final String currentUserId = user?.id ?? "";

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
                return ExpandableListWrapper(
                  initialItems: 2,
                  seeMoreLabel: "nhiệm vụ khác",
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

            // II. THÔNG BÁO QUỸ LỚP (ĐÃ CẬP NHẬT LOGIC TRỪ TIỀN)
            summaryAsync.when(
              loading: () => const Center(child: LinearProgressIndicator()),
              error: (e, s) => const SizedBox(),
              data: (summary) => campaignsAsync.when(
                loading: () => const SizedBox(),
                error: (e, s) => const SizedBox(),
                data: (campaigns) {
                  // --- LOGIC TÍNH TIỀN THỰC TẾ CÒN THIẾU ---
                  int totalRemaining = 0;

                  for (var campaign in campaigns) {
                    final unpaidAsync = ref.watch(
                      fundUnpaidProvider((
                        classId: classId,
                        campaignId: campaign.id,
                      )),
                    );

                    unpaidAsync.whenData((members) {
                      try {
                        // Tìm bản ghi của bạn trong campaign này (dùng dynamic để tránh báo đỏ)
                        final dynamic myRecord = members.cast<dynamic>().firstWhere(
                          (m) => m.userId == currentUserId,
                        );

                        if (myRecord != null && myRecord.isPaid == false) {
                          final int totalMustPay = (campaign.amountPerPerson ?? 0).toInt();
                          
                          // Lấy số tiền đã nộp (thường là trường 'amount' trong fund_members)
                          // Nếu nộp 5k/55k thì remainingAmount/debt sẽ là 50k
                          final int alreadyPaid = (myRecord.amount ?? 0).toInt();
                          
                          final int debt = totalMustPay - alreadyPaid;

                          if (debt > 0) {
                            totalRemaining += debt;
                          }
                        }
                      } catch (e) {
                        // Nếu chưa có record nộp tiền, coi như nợ đủ số tiền chiến dịch
                        totalRemaining += (campaign.amountPerPerson ?? 0).toInt();
                      }
                    });
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: totalRemaining > 0
                          ? const Color(0xFFFFF5F5)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: totalRemaining > 0
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
                            color: totalRemaining > 0
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
                              if (totalRemaining > 0)
                                Text(
                                  "Bạn còn thiếu: ${CurrencyUtils.format(totalRemaining)}",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: const Color(0xFFE53E3E),
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              else
                                Text(
                                  "Bạn đã hoàn thành đóng quỹ",
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.green,
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
                return ExpandableListWrapper(
                  initialItems: 3,
                  seeMoreLabel: "sự kiện khác",
                  children: events.map((e) => EventCardItem(data: e)).toList(),
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
                    .where((g) => g.members.any((m) => m.userId == currentUserId))
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
                            (a, b) => (b.isLeader ? 1 : 0) - (a.isLeader ? 1 : 0),
                          );

                          return ExpandableListWrapper(
                            initialItems: 4,
                            seeMoreLabel: "thành viên khác",
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF101727),
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

// --- WIDGET XỬ LÝ XEM THÊM ---
class ExpandableListWrapper extends StatefulWidget {
  final List<Widget> children;
  final int initialItems;
  final String seeMoreLabel;

  const ExpandableListWrapper({
    super.key,
    required this.children,
    this.initialItems = 5,
    this.seeMoreLabel = "mục khác",
  });

  @override
  State<ExpandableListWrapper> createState() => _ExpandableListWrapperState();
}

class _ExpandableListWrapperState extends State<ExpandableListWrapper> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final bool canExpand = widget.children.length > widget.initialItems;

    final displayList = isExpanded
        ? widget.children
        : widget.children.take(widget.initialItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayList,
        if (canExpand)
          GestureDetector(
            onTap: () => setState(() => isExpanded = !isExpanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              color: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isExpanded
                        ? "Thu gọn"
                        : "Xem thêm ${widget.children.length - widget.initialItems} ${widget.seeMoreLabel}",
                    style: GoogleFonts.roboto(
                      fontSize: 13,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isExpanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 16,
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
