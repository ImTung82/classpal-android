import 'package:flutter/material.dart';

class DeleteEventDialog extends StatelessWidget {
  final String eventName;

  const DeleteEventDialog({super.key, required this.eventName});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Tiêu đề
            const Text(
              'Xóa sự kiện',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101727),
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 16),

            // 2. Nội dung cảnh báo (RichText)
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495565),
                  fontFamily: 'Arimo',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(text: 'Bạn có chắc chắn muốn xóa sự kiện '),
                  TextSpan(
                    text: eventName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101727), // Màu đậm hơn cho tên sự kiện
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // 3. Cảnh báo phụ
            const Text(
              'Hành động này không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(
                  0xFFE7000B,
                ), // Màu đỏ cảnh báo nhẹ hoặc xám tùy thiết kế
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 24),

            // 4. Action Buttons
            Row(
              children: [
                // Nút Hủy
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop(false); // Trả về false
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD0D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Hủy',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF354152),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Nút Xóa (Màu đỏ)
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Trả về true để báo là đồng ý xóa
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(
                        0xFFE7000B,
                      ), // Màu đỏ từ Figma
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Xóa sự kiện',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
