import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CreateNotificationSection extends StatelessWidget {
  const CreateNotificationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F8FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFDCE7FF)),
          ),
          child: Row(
            children: const [
              Icon(LucideIcons.bell, color: Color(0xFF2563EB)),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Gửi thông báo mới",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Là lớp trưởng, bạn có thể gửi thông báo đến tất cả thành viên trong lớp",
                      style:
                          TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            child: const Text(
              "Tạo thông báo mới",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
