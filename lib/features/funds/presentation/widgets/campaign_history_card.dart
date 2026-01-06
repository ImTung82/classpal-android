import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../data/models/fund_models.dart';

class CampaignHistoryCard extends StatelessWidget {
  final FundCampaignHistory history;

  const CampaignHistoryCard({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final campaign = history.campaign;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ===== Title + Status =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  campaign.title,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _statusChip(campaign.isClosed),
            ],
          ),

          const SizedBox(height: 6),

          /// ===== Created date =====
          Text(
            "Ngày tạo: ${_formatDate(campaign.createdAt)}",
            style: GoogleFonts.roboto(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 8),

          /// ===== Amount per person =====
          Text(
            "💰 ${CurrencyUtils.format(campaign.amountPerPerson)} / người",
            style: GoogleFonts.roboto(fontSize: 13),
          ),

          const SizedBox(height: 6),

          /// ===== Members =====
          Text(
            "👥 ${history.paidMembers}/${history.totalMembers} đã đóng",
            style: GoogleFonts.roboto(fontSize: 13),
          ),

          const SizedBox(height: 6),

          /// ===== My status =====
          Row(
            children: [
              Icon(
                history.isPaidByMe
                    ? LucideIcons.checkCircle
                    : LucideIcons.xCircle,
                size: 16,
                color:
                    history.isPaidByMe ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 6),
              Text(
                history.isPaidByMe
                    ? "Bạn đã đóng"
                    : "Bạn chưa đóng",
                style: GoogleFonts.roboto(fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool isClosed) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isClosed
            ? Colors.grey.shade200
            : Colors.green.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isClosed ? "Đã đóng" : "Đang thu",
        style: GoogleFonts.roboto(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: isClosed ? Colors.grey : Colors.green,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "--";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }
}
