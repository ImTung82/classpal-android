import 'package:flutter/material.dart';

class UnregisterEventDialog extends StatelessWidget {
  final String eventName;

  const UnregisterEventDialog({super.key, required this.eventName});

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
            const Text(
              'Hủy đăng ký',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF101727),
                fontFamily: 'Arimo',
              ),
            ),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF495565),
                  fontFamily: 'Arimo',
                  height: 1.5,
                ),
                children: [
                  const TextSpan(
                    text: 'Bạn có chắc chắn muốn hủy tham gia sự kiện ',
                  ),
                  TextSpan(
                    text: eventName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101727),
                    ),
                  ),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFD0D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Giữ lại',
                      style: TextStyle(fontSize: 16, color: Color(0xFF354152)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE7000B),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Hủy đăng ký',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
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
