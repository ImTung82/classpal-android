import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/fund_models.dart';
import '../../../../core/utils/currency_utils.dart';

class PersonalStatusCard extends StatefulWidget {
  final FundCampaign campaign;
  final bool isPaid;
  final List<UnpaidMember> unpaidMembers;

  const PersonalStatusCard({
    super.key,
    required this.campaign,
    required this.isPaid,
    required this.unpaidMembers,
  });

  @override
  State<PersonalStatusCard> createState() => _PersonalStatusCardState();
}

class _PersonalStatusCardState extends State<PersonalStatusCard> {
  bool expanded = false;

  String _formatDate(DateTime? date) {
    if (date == null) return "Không có";
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final unpaidOnly =
        widget.unpaidMembers.where((m) => !m.isPaid).toList();

    final bg =
        widget.isPaid ? const Color(0xFFF0FDF4) : const Color(0xFFFFF7ED);
    final border =
        widget.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFFEDD5);
    final icon =
        widget.isPaid ? LucideIcons.checkCircle : LucideIcons.xCircle;
    final iconColor =
        widget.isPaid ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
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
              Icon(icon, color: iconColor, size: 22),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            "Hạn nộp: ${_formatDate(widget.campaign.deadline)}",
            style: GoogleFonts.roboto(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),
          Text(
            CurrencyUtils.format(widget.campaign.amountPerPerson),
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 6),
          Text(
            widget.isPaid ? "✅ Bạn đã nộp" : "⏳ Bạn chưa nộp",
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.w600,
              color: iconColor,
              fontSize: 12,
            ),
          ),

          /// ===== TOGGLE DANH SÁCH =====
          if (unpaidOnly.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
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
                    expanded
                        ? LucideIcons.chevronUp
                        : LucideIcons.chevronDown,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            Text(
              "🎉 Tất cả đã nộp",
              style: GoogleFonts.roboto(
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          /// ===== DANH SÁCH CHƯA NỘP =====
          if (expanded && unpaidOnly.isNotEmpty) ...[
            const SizedBox(height: 8),
            Column(
              children: unpaidOnly.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
