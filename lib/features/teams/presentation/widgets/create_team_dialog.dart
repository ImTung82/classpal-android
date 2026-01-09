import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateTeamDialog extends StatefulWidget {
  // Callback chỉ trả về tên (vì màu tự động)
  final Function(String name) onSubmit; 
  final String? initialName; // Hỗ trợ edit tên cũ

  const CreateTeamDialog({
    super.key, 
    required this.onSubmit,
    this.initialName,
  });

  @override
  State<CreateTeamDialog> createState() => _CreateTeamDialogState();
}

class _CreateTeamDialogState extends State<CreateTeamDialog> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? "");
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialName != null;

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
            Center(
              child: Text(
                isEditing ? "Đổi tên tổ" : "Tạo tổ mới", 
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 24),
            
            Text("Tên tổ", style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "VD: Tổ 1",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        if (_nameController.text.trim().isEmpty) return;
                        widget.onSubmit(_nameController.text.trim());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isEditing ? "Lưu" : "Tạo"),
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