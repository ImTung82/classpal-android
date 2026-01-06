import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/utils/storage_utils.dart';

Future<void> showCreateExpenseOverlay(
  BuildContext context, {
  required Future<void> Function({
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  })
  onSubmit,
}) async {
  final titleController = TextEditingController();
  final amountController = TextEditingController();
  final dateController = TextEditingController();
  final evidenceController = TextEditingController();

  final ImagePicker picker = ImagePicker();
  DateTime? selectedDate;
  XFile? selectedImage;

  String? titleError;
  String? amountError;
  String? dateError;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      final width = MediaQuery.of(context).size.width;
      bool isSubmitting = false;
      return StatefulBuilder(
        builder: (context, setState) {
          void validateAndSubmit() async {
            if (isSubmitting) return;

            try {
              String? _titleError;
              String? _amountError;
              String? _dateError;

              final title = titleController.text.trim();
              final amountText = amountController.text.trim();

              if (title.isEmpty) {
                _titleError = "Vui lòng nhập mô tả";
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

              if (selectedDate == null) {
                _dateError = "Vui lòng chọn ngày chi";
              }

              setState(() {
                titleError = _titleError;
                amountError = _amountError;
                dateError = _dateError;
              });

              if (_titleError != null ||
                  _amountError != null ||
                  _dateError != null) {
                return;
              }

              setState(() => isSubmitting = true);

              String? imageUrl;
              if (selectedImage != null) {
                imageUrl = await StorageUtils.uploadEvidence(selectedImage!);
              }

              await onSubmit(
                title: title,
                amount: amount!,
                spentAt: selectedDate,
                evidenceUrl: imageUrl,
              );

              await Future.delayed(const Duration(milliseconds: 500));

              if (context.mounted) {
                Navigator.pop(context);
              }
            } catch (e, s) {
              debugPrint("❌ Lỗi upload / submit: $e");
              debugPrintStack(stackTrace: s);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Không thể thêm khoản chi. Vui lòng thử lại.",
                      style: GoogleFonts.roboto(),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            } finally {
              if (context.mounted) {
                setState(() => isSubmitting = false);
              }
            }
          }

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 24,
            ),
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Thêm khoản chi",
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _label("Mô tả"),
                    _input(titleController, hint: "VD: Tiền photo tài liệu"),
                    _error(titleError),

                    const SizedBox(height: 12),

                    _label("Số tiền (VNĐ)"),
                    _input(
                      amountController,
                      hint: "50000",
                      keyboardType: TextInputType.number,
                    ),
                    _error(amountError),

                    const SizedBox(height: 12),

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
                          setState(() {
                            selectedDate = date;
                            dateController.text =
                                "${date.day}/${date.month}/${date.year}";
                            dateError = null;
                          });
                        }
                      },
                    ),
                    _error(dateError),

                    const SizedBox(height: 16),

                    _label("Hóa đơn (nếu có)"),
                    const SizedBox(height: 6),

                    GestureDetector(
                      onTap: () async {
                        final image = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 80,
                        );
                        if (image != null) {
                          setState(() {
                            selectedImage = image;
                            evidenceController.text = image.name;
                          });
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.image_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                evidenceController.text.isEmpty
                                    ? "Chọn ảnh hóa đơn"
                                    : evidenceController.text,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSubmitting
                                ? null
                                : () => Navigator.pop(context),
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
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : validateAndSubmit,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 44),
                              backgroundColor: const Color(0xFFDC2626),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
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
      style: GoogleFonts.roboto(color: Colors.red.shade600, fontSize: 12),
    ),
  );
}

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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
