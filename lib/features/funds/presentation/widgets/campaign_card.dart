import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/fund_models.dart';
import '../../../../core/utils/currency_utils.dart';

class CampaignCard extends StatefulWidget {
  final FundCampaign campaign;
  final List<UnpaidMember> members;
  final void Function(UnpaidMember member) onConfirmPaid;

  const CampaignCard({
    super.key,
    required this.campaign,
    required this.members,
    required this.onConfirmPaid,
  });

  @override
  State<CampaignCard> createState() => _CampaignCardState();
}

class _CampaignCardState extends State<CampaignCard> {
  bool showUnpaid = false;
  @override
  Widget build(BuildContext context) {
    final unpaidOnly =
        widget.members.where((m) => !m.isPaid).toList();

    double progress = widget.campaign.totalMemberCount == 0
        ? 0
        : widget.campaign.paidCount /
            widget.campaign.totalMemberCount;

    String formatDate(DateTime? date) {
      if (date == null) return "Không có";
      return "${date.day.toString().padLeft(2, '0')}/"
          "${date.month.toString().padLeft(2, '0')}/"
          "${date.year}";
    }

    return Container(
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
                widget.campaign.title,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Đang thu",
                  style: GoogleFonts.roboto(
                    color: Colors.green[800],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          
          Text(
            "${CurrencyUtils.format(widget.campaign.amountPerPerson)}/người • "
            "Hạn: ${formatDate(widget.campaign.deadline)}",
            style:
                GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12),
          ),

          const SizedBox(height: 16),

        
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF22C55E),
              ),
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${widget.campaign.paidCount}/${widget.campaign.totalMemberCount}",
              style:
                  GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
            ),
          ),

          const SizedBox(height: 16),

          /// EXPAND HEADER
          if (unpaidOnly.isNotEmpty)
            InkWell(
              onTap: () {
                setState(() {
                  showUnpaid = !showUnpaid;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Danh sách chưa nộp (${unpaidOnly.length})",
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Icon(
                    showUnpaid
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            )
          else
            Text(
              "🎉 Tất cả đã nộp",
              style: GoogleFonts.roboto(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),

          /// EXPAND CONTENT
          if (showUnpaid && unpaidOnly.isNotEmpty) ...[
            const SizedBox(height: 8),

            Column(
              children: unpaidOnly.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        LucideIcons.xCircle,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              m.fullName,
                              style: GoogleFonts.roboto(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (m.studentCode.isNotEmpty)
                              Text(
                                m.studentCode,
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),

                      ElevatedButton(
                        onPressed: () =>
                            widget.onConfirmPaid(m),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF22C55E),
                          padding:
                              const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Đã nộp",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.send, size: 16),
              label: const Text("Gửi nhắc nhở (5 người)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF3D00), // Cam đỏ
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
