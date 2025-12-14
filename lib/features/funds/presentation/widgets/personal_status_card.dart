import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/fund_models.dart';
import '../../../../core/utils/currency_utils.dart'; // Import tiện ích

class PersonalStatusCard extends StatelessWidget {
  final FundCampaign campaign;
  const PersonalStatusCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4), // Xanh rất nhạt
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(campaign.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 15)),
              const Icon(LucideIcons.checkCircle, color: Colors.green, size: 24),
            ],
          ),
          Text("Hạn nộp: ${campaign.deadline}", style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),
          // Format tiền ở đây
          Text(CurrencyUtils.format(campaign.amountPerPerson), style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
        ],
      ),
    );
  }
}