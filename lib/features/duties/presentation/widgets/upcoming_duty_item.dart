import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/duty_models.dart';

class UpcomingDutyItem extends StatelessWidget {
  final DutyTask task;

  const UpcomingDutyItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(task.title, style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 14)),
              Text(task.assignedTo, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
            ],
          ),
          Text(task.dateRange, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}