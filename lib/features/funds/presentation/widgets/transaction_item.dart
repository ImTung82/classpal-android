import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/fund_models.dart';
import '../../../../core/utils/currency_utils.dart'; // Import tiện ích

class TransactionItem extends StatelessWidget {
  final FundTransaction transaction;

  const TransactionItem({super.key, required this.transaction});
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2), // Đỏ rất nhạt
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECDD3)), // Viền đỏ nhạt
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.trendingDown,
              color: Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${_formatDate(transaction.createdAt)}"
                  "${transaction.payerName != null ? " • Bởi: ${transaction.payerName}" : ""}",
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            // Logic thêm dấu - hoặc + và format tiền
            "${transaction.isExpense ? '-' : '+'}${CurrencyUtils.format(transaction.amount)}",
            style: GoogleFonts.roboto(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
