import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showCreateCampaignOverlay(
  BuildContext context, {
  required void Function({
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  }) onSubmit,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final deadlineController = TextEditingController();

  DateTime? selectedDeadline;

  String? titleError;
  String? amountError;
  String? deadlineError;

  final borderColor = Colors.grey.shade300;
  final primaryBlue = const Color(0xFF1D4ED8);

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;

      return StatefulBuilder(
        builder: (context, setState) {
          void validateAndSubmit() {
            String? _titleError;
            String? _amountError;
            String? _deadlineError;

            final title = titleController.text.trim();
            final amountText = amountController.text.trim();

            if (title.isEmpty) {
              _titleError = "Vui lòng nhập tên khoản thu";
            }

            int? amount;
            if (amountText.isEmpty) {
              _amountError = "Vui lòng nhập số tiền";
            } else {
              amount = int.tryParse(amountText);
              if (amount == null || amount <= 0) {
                _amountError = "Số tiền không hợp lệ";
              }
            }

            if (selectedDeadline == null) {
              _deadlineError = "Vui lòng chọn hạn nộp";
            }

            setState(() {
              titleError = _titleError;
              amountError = _amountError;
              deadlineError = _deadlineError;
            });

            if (_titleError != null ||
                _amountError != null ||
                _deadlineError != null) {
              return;
            }

            onSubmit(
              title: title,
              amountPerPerson: amount!,
              deadline: selectedDeadline,
            );

            Navigator.pop(context);
          }

          return Dialog(
  insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
  backgroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: borderColor),
  ),
  child: ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width * 0.9,
      maxHeight: MediaQuery.of(context).size.height * 0.85,
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tạo khoản thu mới",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          _label("Tên khoản thu"),
          _inputField(
            controller: titleController,
            hint: "VD: Quỹ lớp Học kỳ 2",
            borderColor: borderColor,
          ),
          _error(titleError),

          const SizedBox(height: 12),

          _label("Số tiền/người (VNĐ)"),
          _inputField(
            controller: amountController,
            hint: "100000",
            keyboardType: TextInputType.number,
            borderColor: borderColor,
          ),
          _error(amountError),

          const SizedBox(height: 12),

          _label("Hạn nộp"),
          TextField(
            controller: deadlineController,
            readOnly: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
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
                setState(() {
                  selectedDeadline = date;
                  deadlineController.text =
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}";
                  deadlineError = null;
                });
              }
            },
          ),
          _error(deadlineError),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Hủy"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: validateAndSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                  ),
                  child: const Text(
                    "Tạo khoản thu",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

        },
      );
    },
  );
}


Widget _label(String text) =>
    Text(text, style: GoogleFonts.roboto(fontSize: 13));

Widget _error(String? text) {
  if (text == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Text(
      text,
      style: GoogleFonts.roboto(
        color: Colors.red.shade600,
        fontSize: 12,
      ),
    ),
  );
}

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(color: Color(0xFF1D4ED8)),
      ),
    ),
  );
}
