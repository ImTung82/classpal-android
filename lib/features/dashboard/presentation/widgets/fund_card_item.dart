import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../funds/presentation/view_models/fund_view_model.dart';
import '../../../../core/utils/currency_utils.dart';

class FundCardItem extends ConsumerWidget {
  final String classId;
  final String campaignId;
  final String campaignTitle;
  final int amountPerPerson;

  const FundCardItem({
    super.key,
    required this.classId,
    required this.campaignId,
    required this.campaignTitle,
    required this.amountPerPerson,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe danh sách chưa nộp riêng cho campaignId này
    final unpaidAsync = ref.watch(
      fundUnpaidProvider((classId: classId, campaignId: campaignId)),
    );

    return unpaidAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      ),
      error: (e, s) => const SizedBox(),
      data: (members) {
        final unpaidList = members.where((m) => !m.isPaid).toList();

        // Nếu quỹ này đã nộp đủ, không hiển thị card này
        if (unpaidList.isEmpty) return const SizedBox();

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF5F5), // Nền đỏ nhạt
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFED7D7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header của Card Quỹ
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.wallet,
                      color: Color(0xFFE53E3E),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Chiến dịch: $campaignTitle",
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: const Color(0xFF101727),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Danh sách tối đa 3 sinh viên để tránh card quá dài trên trang chủ
              ...unpaidList.take(3).map((m) => _buildStudentItem(m)),

              if (unpaidList.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 4),
                  child: Text(
                    "Và ${unpaidList.length - 3} sinh viên khác chưa nộp...",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // Widget con hiển thị từng dòng sinh viên
  Widget _buildStudentItem(dynamic member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.user,
              color: Color(0xFF64748B),
              size: 16,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  "MSSV: ${member.studentCode}",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            CurrencyUtils.format(amountPerPerson),
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: const Color(0xFFE53E3E),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
