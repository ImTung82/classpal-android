import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/fund_view_model.dart';
import '../widgets/transaction_item.dart';
import '../widgets/campaign_card.dart';
import '../../../../core/utils/currency_utils.dart'; // Import tiện ích
import '../widgets/create_campaign.dart';
import '../widgets/create_expense.dart';

class OwnerFundContent extends ConsumerWidget {
  final String classId;
  const OwnerFundContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(fundSummaryProvider(classId));
    final campaignsAsync = ref.watch(fundCampaignsProvider(classId));
    final transactionsAsync = ref.watch(fundTransactionsProvider(classId));


    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Quản lý quỹ lớp",
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

          // 1. Thống kê nhỏ (Thu/Chi)
          summaryAsync.when(
            loading: () => const SizedBox(),
            error: (e, s) => const SizedBox(),
            data: (summary) => Column(
              children: [
                _buildSmallStatCard(
                  "Tổng thu",
                  CurrencyUtils.format(summary.totalIncome),
                  LucideIcons.trendingUp,
                  const Color(0xFFDCFCE7),
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildSmallStatCard(
                  "Tổng chi",
                  CurrencyUtils.format(summary.totalExpense),
                  LucideIcons.trendingDown,
                  const Color(0xFFFEE2E2),
                  Colors.red,
                ),
                const SizedBox(height: 12),

                // 2. Card Tồn quỹ (Màu Tím)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A84F8), Color(0xFF9333EA)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF9333EA).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          LucideIcons.dollarSign,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Tồn quỹ",
                            style: GoogleFonts.roboto(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          // Format tiền ở đây
                          Text(
                            CurrencyUtils.format(summary.balance),
                            style: GoogleFonts.roboto(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 3. Khoản thu (Collection)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Khoản thu",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await showCreateCampaignOverlay(
                          context,
                          onSubmit:
                              ({
                                required String title,
                                required int amountPerPerson,
                                DateTime? deadline,
                              }) async {
                                await ref
                                    .read(fundActionProvider)
                                    .createCampaign(
                                      classId: classId,
                                      title: title,
                                      amountPerPerson: amountPerPerson,
                                      deadline: deadline,
                                    );
                              },
                        );
                      },

                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text("Tạo khoản thu"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 42),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Nội dung sau này (CampaignCard)
                campaignsAsync.when(
  loading: () => const CircularProgressIndicator(),
  error: (e, s) => Text("Lỗi: $e"),
  data: (campaigns) {
    if (campaigns.isEmpty) {
      return const Text("Chưa có khoản thu");
    }

    return Column(
      children: campaigns.map((campaign) {
        final unpaidAsync = ref.watch(
          fundUnpaidProvider(
            (classId: classId, campaignId: campaign.id),
          ),
        );

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: unpaidAsync.when(
            loading: () => CampaignCard(
              campaign: campaign,
              members: const [],
              onConfirmPaid: (_) {},
            ),
            error: (e, s) => Text("Lỗi thành viên: $e"),
            data: (members) => CampaignCard(
              campaign: campaign,
              members: members, // 🔥 ĐÃ ĐÚNG THEO CAMPAIGN
              onConfirmPaid: (member) async {
                await ref.read(fundActionProvider).confirmPaid(
                      classId: classId,
                      campaign: campaign,
                      member: member,
                    );
              },
            ),
          ),
        );
      }).toList(),
    );
  },
),


              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. Số chi (Expenses)
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Số chi",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        bool success = false;

                        await showCreateExpenseOverlay(
                          context,
                          onSubmit:
                              ({
                                required String title,
                                required int amount,
                                DateTime? spentAt,
                                String? evidenceUrl,
                              }) async {
                                await ref
                                    .read(fundActionProvider)
                                    .addExpense(
                                      classId: classId,
                                      title: title,
                                      amount: amount,
                                      spentAt: spentAt,
                                      evidenceUrl: evidenceUrl,
                                    );
                                success = true;
                              },
                        );

                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Đã thêm khoản chi thành công",
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: const Color(0xFF16A34A),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },

                      icon: const Icon(LucideIcons.plus, size: 14),
                      label: const Text("Thêm khoản chi"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 42),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                transactionsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, s) => Text("Lỗi: $e"),
                  data: (transactions) {
                    if (transactions.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            "Chưa có khoản chi",
                            style: GoogleFonts.roboto(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: transactions
                          .map((t) => TransactionItem(transaction: t))
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSmallStatCard(
    String title,
    String value,
    IconData icon,
    Color bgIcon,
    Color colorIcon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgIcon,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colorIcon, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
