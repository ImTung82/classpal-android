import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// [SỬA LẠI ĐÚNG ĐƯỜNG DẪN]
import '../../data/models/dashboard_models.dart'; 

class DutyListItem extends StatelessWidget {
  final DutyData data;

  const DutyListItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    Color iconColor;

    // Logic hiển thị màu sắc theo trạng thái
    if (data.status == 'In Progress') {
      statusColor = const Color(0xFFFFE4C8); // Cam nhạt
      statusText = "Đang thực hiện";
      statusIcon = LucideIcons.alertCircle;
      iconColor = Colors.orange;
    } else if (data.status == 'Upcoming') {
      statusColor = Colors.grey[200]!;
      statusText = "Sắp tới";
      statusIcon = LucideIcons.clock;
      iconColor = Colors.grey;
    } else {
      statusColor = const Color(0xFFDCFCE7); // Xanh nhạt
      statusText = "Hoàn thành";
      statusIcon = LucideIcons.checkCircle;
      iconColor = Colors.green;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB), // Xám rất nhạt
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.groupName, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(data.taskName, style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(20)),
            child: Text(
              statusText,
              style: GoogleFonts.roboto(
                fontSize: 11, 
                fontWeight: FontWeight.bold,
                color: data.status == 'Done' ? Colors.green[800] : (data.status == 'In Progress' ? Colors.orange[800] : Colors.grey[700])
              ),
            ),
          )
        ],
      ),
    );
  }
}