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

// Import ViewModels và Utils
import '../../../funds/presentation/view_models/fund_view_model.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../auth/data/repositories/auth_repository.dart';

class OwnerDashboardContent extends ConsumerWidget {
  final String classId;

  const OwnerDashboardContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider(classId));
    final dutiesAsync = ref.watch(dutiesProvider(classId));
    final eventsAsync = ref.watch(eventsProvider(classId));
    final campaignsAsync = ref.watch(fundCampaignsProvider(classId));

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

            // I. THỐNG KÊ
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
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

            // II. NHIỆM VỤ TRỰC NHẬT (ÁP DỤNG XEM THÊM)
            _buildSectionTitle("Nhiệm vụ trực nhật"),
            dutiesAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Lỗi tải nhiệm vụ"),
              data: (duties) => duties.isEmpty
                  ? const Text(
                      "Chưa có lịch trực nhật",
                      style: TextStyle(color: Colors.grey),
                    )
                  : ExpandableListWrapper(
                      initialItems: 3,
                      seeMoreLabel: "nhiệm vụ khác",
                      children: duties
                          .map((d) => DutyListItem(data: d))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // III. SỰ KIỆN ĐANG MỞ (ÁP DỤNG XEM THÊM)
            _buildSectionTitle("Sự kiện đang mở"),
            eventsAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const Text("Lỗi tải sự kiện"),
              data: (events) => events.isEmpty
                  ? const Text(
                      "Không có sự kiện sắp tới",
                      style: TextStyle(color: Colors.grey),
                    )
                  : ExpandableListWrapper(
                      initialItems: 3,
                      seeMoreLabel: "sự kiện khác",
                      children: events
                          .map((e) => EventCardItem(data: e))
                          .toList(),
                    ),
            ),

            const SizedBox(height: 24),

            // IV. SINH VIÊN CHƯA NỘP QUỸ LỚP (ÁP DỤNG XEM THÊM)
            _buildSectionTitle("Sinh viên chưa nộp quỹ lớp"),
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

                final Map<String, Map<String, dynamic>> aggregatedDebts = {};

                for (var campaign in campaigns) {
                  final unpaidData = ref.watch(
                    fundUnpaidProvider((
                      classId: classId,
                      campaignId: campaign.id,
                    )),
                  );
                  unpaidData.whenData((members) {
                    final int amount = campaign.amountPerPerson.toInt();
                    for (final m in members) {
                      if (m.isPaid == false) {
                        final String sCode = m.studentCode?.toString() ?? "N/A";
                        if (aggregatedDebts.containsKey(sCode)) {
                          aggregatedDebts[sCode]!['debt'] =
                              (aggregatedDebts[sCode]!['debt'] as int) + amount;
                        } else {
                          aggregatedDebts[sCode] = {
                            'name': m.fullName ?? "Ẩn danh",
                            'code': sCode,
                            'debt': amount,
                          };
                        }
                      }
                    }
                  });
                }

                if (aggregatedDebts.isEmpty) {
                  return const Text(
                    "Cả lớp đã hoàn thành nộp quỹ!",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }

                final sortedDebtList = aggregatedDebts.values.toList()
                  ..sort(
                    (a, b) => (b['debt'] as int).compareTo(a['debt'] as int),
                  );

                return ExpandableListWrapper(
                  initialItems: 5,
                  seeMoreLabel: "sinh viên chưa đóng",
                  children: sortedDebtList
                      .map(
                        (data) => UnpaidStudentItem(
                          name: data['name'] as String,
                          studentCode: data['code'] as String,
                          totalAmount: CurrencyUtils.format(
                            data['debt'] as int,
                          ),
                        ),
                      )
                      .toList(),
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
