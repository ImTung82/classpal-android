import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/asset_view_model.dart';

Future<bool?> showAddAssetOverlay(
  BuildContext context, {
  required String classId,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => AddAssetOverlay(classId: classId),
  );
}


class AddAssetOverlay extends ConsumerStatefulWidget {
  final String classId;

  const AddAssetOverlay({super.key, required this.classId});

  @override
  ConsumerState<AddAssetOverlay> createState() => _AddAssetOverlayState();
}

class _AddAssetOverlayState extends ConsumerState<AddAssetOverlay> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _noteController = TextEditingController();


  bool _isSubmitting = false;

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  /// ===== VALIDATORS =====

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập tên tài sản';
    }
    if (value.trim().length < 3) {
      return 'Tên tài sản phải ít nhất 3 ký tự';
    }
    return null;
  }

  String? _validateQuantity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số lượng';
    }
    final qty = int.tryParse(value);
    if (qty == null) {
      return 'Số lượng phải là số';
    }
    if (qty <= 0) {
      return 'Số lượng phải lớn hơn 0';
    }
    return null;
  }

  String? _validateNote(String? value) {
    if (value != null && value.length > 200) {
      return 'Ghi chú tối đa 200 ký tự';
    }
    return null;
  }

  /// ===== SUBMIT =====
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref
          .read(assetRepositoryProvider)
          .addAsset(
            classId: widget.classId,
            name: _nameController.text.trim(),
            totalQuantity: int.parse(_quantityController.text),
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      ref.invalidate(assetListWithStatusProvider(widget.classId));
      ref.invalidate(assetSummaryProvider(widget.classId));

      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi thêm tài sản: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thêm tài sản mới',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                /// NAME
                const Text('Tên tài sản'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  decoration: _inputDecoration(hint: 'VD: Remote điều hòa'),
                ),

                const SizedBox(height: 16),

                /// QUANTITY
                const Text('Số lượng'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: _validateQuantity,
                  decoration: _inputDecoration(hint: 'VD: 1'),
                ),

                const SizedBox(height: 16),

                /// NOTE
                const Text('Ghi chú'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  validator: _validateNote,
                  decoration: _inputDecoration(
                    hint: 'Không bắt buộc (tối đa 200 ký tự)',
                  ),
                ),

                const SizedBox(height: 24),

                /// ACTIONS
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: const Color(0xFFF5F5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF155DFC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Thêm tài sản',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
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
      ),
    );
  }
}
