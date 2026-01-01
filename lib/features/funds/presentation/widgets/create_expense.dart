import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showCreateExpenseOverlay(
  BuildContext context, {
  required Future<void> Function({
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  }) onSubmit,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final evidenceController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  XFile? selectedImage;
  DateTime? selectedDate;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final width = MediaQuery.of(context).size.width;

      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade300),
        ),
        child: Container(
          width: width * 0.85,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Title =====
              Text(
                "Thêm khoản chi",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ===== Mô tả =====
              _label("Mô tả"),
              _input(
                titleController,
                hint: "VD: Tiền photo tài liệu",
              ),

              const SizedBox(height: 16),

              // ===== Số tiền =====
              _label("Số tiền (VNĐ)"),
              _input(
                amountController,
                hint: "50000",
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 16),

              // ===== Ngày chi =====
              _label("Ngày chi"),
              _input(
                dateController,
                readOnly: true,
                suffix: Icons.calendar_today_outlined,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDate = date;
                    dateController.text =
                        "${date.day}/${date.month}/${date.year}";
                  }
                },
              ),

              const SizedBox(height: 16),

              // ===== Hóa đơn =====
              _label("Hóa đơn (nếu có)"),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final image =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    selectedImage = image;
                    evidenceController.text = image.name;
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.image_outlined,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          evidenceController.text.isEmpty
                              ? "Chọn ảnh hóa đơn"
                              : evidenceController.text,
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: evidenceController.text.isEmpty
                                ? Colors.grey
                                : Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ===== Buttons =====
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Hủy",
                        style: GoogleFonts.roboto(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await onSubmit(
                          title: titleController.text.trim(),
                          amount: int.parse(amountController.text),
                          spentAt: selectedDate,
                          evidenceUrl: evidenceController.text.isEmpty
                              ? null
                              : evidenceController.text,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: const Color(0xFFDC2626),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "Thêm khoản chi",
                        style: GoogleFonts.roboto(
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
    },
  );
}

/// =====================
/// UI HELPERS
/// =====================

Widget _label(String text) => Text(
      text,
      style: GoogleFonts.roboto(fontSize: 13),
    );

Widget _input(
  TextEditingController controller, {
  String? hint,
  bool readOnly = false,
  IconData? suffix,
  VoidCallback? onTap,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextField(
    controller: controller,
    readOnly: readOnly,
    onTap: onTap,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffix != null ? Icon(suffix, size: 18) : null,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade500),
      ),
    ),
  );
}
