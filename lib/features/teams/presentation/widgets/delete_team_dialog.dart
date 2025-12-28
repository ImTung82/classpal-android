import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DeleteTeamDialog extends StatelessWidget {
  final String teamName;
  final VoidCallback onDelete;

  const DeleteTeamDialog({
    super.key,
    required this.teamName,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Icon cảnh báo (Optional - Thêm vào cho sinh động)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.warning_amber_rounded, color: Colors.red.shade400, size: 32),
            ),
            const SizedBox(height: 16),

            // 2. Tiêu đề
            Text(
              "Xóa tổ?",
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 3. Nội dung cảnh báo
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                children: [
                  const TextSpan(text: "Bạn có chắc muốn xóa "),
                  TextSpan(
                    text: teamName,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const TextSpan(text: " không?\nThành viên trong tổ sẽ trở về trạng thái "),
                  const TextSpan(
                    text: "\"Chưa phân tổ\"",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const TextSpan(text: "."),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 4. Buttons (Hủy / Xóa)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(color: Colors.grey.shade300),
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text("Hủy"),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        onDelete();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444), // Màu đỏ cảnh báo
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Xóa"),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}