import 'dart:math'; // Import thư viện để random màu
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateTeamDialog extends StatefulWidget {
  final Function(String name, int color) onSubmit;

  const CreateTeamDialog({super.key, required this.onSubmit});

  @override
  State<CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<CreateTeamDialog> {
  final TextEditingController _nameController = TextEditingController();

  // Danh sách bảng màu (Hệ thống sẽ tự random trong list này)
  final List<int> _palette = [
    0xFF0EA5E9, // Xanh Sky
    0xFFD946EF, // Tím Fuchsia
    0xFF10B981, // Xanh Emerald
    0xFFF97316, // Cam Orange
    0xFFEF4444, // Đỏ Red
    0xFF8B5CF6, // Tím Violet
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tiêu đề
            Center(
              child: Text(
                "Tạo tổ mới",
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Input Tên tổ
            Text("Tên tổ", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true, // Tự động focus vào ô nhập khi mở dialog
              decoration: InputDecoration(
                hintText: "VD: Tổ 5",
                hintStyle: GoogleFonts.roboto(color: Colors.grey[400]),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF9333EA))),
              ),
            ),

            const SizedBox(height: 32),

            // 3. Buttons
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        foregroundColor: Colors.black87,
                      ),
                      child: Text("Hủy", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty) return;
                        
                        // [LOGIC MỚI] Random màu tự động
                        final randomColor = _palette[Random().nextInt(_palette.length)];
                        
                        widget.onSubmit(_nameController.text.trim(), randomColor);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text("Tạo tổ", style: GoogleFonts.roboto(fontWeight: FontWeight.bold)),
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