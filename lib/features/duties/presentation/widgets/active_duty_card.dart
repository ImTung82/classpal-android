import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/duty_models.dart';

class ActiveDutyCard extends StatelessWidget {
  final DutyTask task;

  const ActiveDutyCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280, // Chiều rộng cố định để scroll ngang
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(task.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Text(task.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12)),
          const SizedBox(height: 12),
          Text(task.dateRange, style: GoogleFonts.roboto(color: Colors.grey[500], fontSize: 12)),
          const Spacer(),
          // Assigned To & Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.users, size: 16, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(task.assignedTo, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: Colors.blue)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(LucideIcons.bell, size: 14),
                label: const Text("Nhắc"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}