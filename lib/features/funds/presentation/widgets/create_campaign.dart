import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showCreateCampaignOverlay(
  BuildContext context, {
  required void Function({
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  })
  onSubmit,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final deadlineController = TextEditingController();
  DateTime? selectedDeadline;

  final borderColor = Colors.grey.shade300;
  final primaryBlue = const Color(0xFF1D4ED8); // xanh đậm hơn

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: borderColor), // 👈 viền xám nhẹ
        ),
        backgroundColor: Colors.white,
        child: Container(
          width: screenWidth * 0.85,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== Title =====
              Text(
                "Tạo khoản thu mới",
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ===== Tên khoản thu =====
              Text("Tên khoản thu", style: GoogleFonts.roboto(fontSize: 13)),
              const SizedBox(height: 6),
              _inputField(
                controller: titleController,
                hint: "VD: Quỹ lớp Học kỳ 2",
                borderColor: borderColor,
              ),
              const SizedBox(height: 16),

              // ===== Số tiền/người =====
              Text(
                "Số tiền/người (VNĐ)",
                style: GoogleFonts.roboto(fontSize: 13),
              ),
              const SizedBox(height: 6),
              _inputField(
                controller: amountController,
                hint: "100000",
                keyboardType: TextInputType.number,
                borderColor: borderColor,
              ),
              const SizedBox(height: 16),

              // ===== Hạn nộp =====
              Text("Hạn nộp", style: GoogleFonts.roboto(fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: deadlineController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    selectedDeadline = date;
                    deadlineController.text =
                        "${date.day.toString().padLeft(2, '0')}/"
                        "${date.month.toString().padLeft(2, '0')}/"
                        "${date.year}";
                  }
                },
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
                        foregroundColor: Colors.black, // 👈 chữ đen
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        "Hủy",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onSubmit(
                          title: titleController.text.trim(),
                          amountPerPerson: int.parse(amountController.text),
                          deadline: selectedDeadline,
                        );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        "Tạo khoản thu",
                        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
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

/// ===== Reusable input =====
Widget _inputField({
  required TextEditingController controller,
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  required Color borderColor,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1D4ED8)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}
