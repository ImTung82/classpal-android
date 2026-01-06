import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../view_models/fund_view_model.dart';
import '../widgets/transaction_item.dart';
import '../widgets/personal_status_card.dart';
import '../../../../core/utils/currency_utils.dart'; 
import '../widgets/campaign_history_card.dart';

class StudentFundContent extends ConsumerWidget {
  final String classId;

  const StudentFundContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(fundSummaryProvider(classId));
    final transactionsAsync = ref.watch(fundTransactionsProvider(classId));
    final campaignsAsync = ref.watch(fundCampaignsProvider(classId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quỹ lớp",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Theo dõi thu chi minh bạch",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          /// 1. Overview
          summaryAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
            data: (summary) => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF00C853),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tồn quỹ hiện tại",
                    style: GoogleFonts.roboto(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtils.format(summary.balance),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildDetailBox(
                        "Tổng thu",
                        CurrencyUtils.format(summary.totalIncome),
                      ),
                      const SizedBox(width: 12),
                      _buildDetailBox(
                        "Tổng chi",
                        CurrencyUtils.format(summary.totalExpense),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// 2. Trạng thái nộp tiền
          Text(
            "Trạng thái nộp tiền của bạn",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          campaignsAsync.when(
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
            data: (campaigns) {
              if (campaigns.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "Hiện tại chưa có khoản thu nào",
                    style: GoogleFonts.roboto(color: Colors.grey),
                  ),
                );
              }

              final myId = Supabase.instance.client.auth.currentUser?.id;

              return Column(
                children: campaigns.map((campaign) {
                  final unpaidAsync = ref.watch(
                    fundUnpaidProvider((
                      classId: classId,
                      campaignId: campaign.id,
                    )),
                  );

                  return unpaidAsync.when(
                    loading: () => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PersonalStatusCard(
                        campaign: campaign,
                        isPaid: false,
                        unpaidMembers: const [],
                      ),
                    ),
                    error: (_, __) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: PersonalStatusCard(
                        campaign: campaign,
                        isPaid: false,
                        unpaidMembers: const [],
                      ),
                    ),
                    data: (members) {
                      /// 🔥 xác định trạng thái của SINH VIÊN HIỆN TẠI
                      final isUnpaid =
                          myId != null &&
                          members.any((m) => m.userId == myId && !m.isPaid);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: PersonalStatusCard(
                          campaign: campaign,
                          isPaid: !isUnpaid,
                          unpaidMembers: members, // 🔥 QUAN TRỌNG
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          /// 3. Chi tiêu gần đây
          Text(
            "Chi tiêu gần đây",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          transactionsAsync.when(
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
            data: (list) {
              if (list.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    "Chưa có dữ liệu",
                    style: GoogleFonts.roboto(color: Colors.grey),
                  ),
                );
              }

              return Column(
                children: list
                    .map((t) => TransactionItem(transaction: t))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            "Lịch sử khoản thu",
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Consumer(
            builder: (context, ref, _) {
              final historyAsync = ref.watch(
                fundCampaignHistoryProvider(classId),
              );

              return historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, s) => Text("Lỗi tải lịch sử: $e"),
                data: (histories) {
                  if (histories.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        "Chưa có lịch sử khoản thu",
                        style: GoogleFonts.roboto(color: Colors.grey),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Vuốt để xem thêm lịch sử",
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Container(
                        height: 400,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: histories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return CampaignHistoryCard(
                              history: histories[index],
                            );
                          },
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
    );
  }

  Widget _buildDetailBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.roboto(
                color: Colors.white.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.roboto(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
