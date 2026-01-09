import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String content;
  final String time;
  final bool unread;
  final VoidCallback? onDelete;
  const NotificationCard({
    super.key,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.content,
    required this.time,
    required this.unread,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unread ? const Color(0xFFBFDBFE) : const Color(0xFFF3F4F6),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (unread)
                      const Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: Icon(Icons.circle, size: 6, color: Colors.blue),
                      ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onDelete,
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      time,
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                    const Spacer(),
                    if (unread)
                      const Text(
                        "Đánh dấu đã đọc",
                        style: TextStyle(fontSize: 11, color: Colors.blue),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
