import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF7C3AED),
            shape: BoxShape.circle,
          ),
          child: const Icon(LucideIcons.bell, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Thông báo",
              style: GoogleFonts.roboto(
                  fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "2 thông báo chưa đọc",
              style: GoogleFonts.roboto(
                  fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            "Đánh dấu tất cả đã đọc",
            style: TextStyle(fontSize: 12),
          ),
        )
      ],
    );
  }
}
