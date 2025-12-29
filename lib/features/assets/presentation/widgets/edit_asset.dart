import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/asset_view_model.dart';

void showEditAssetOverlay(
  BuildContext context, {
  required String classId,
  required String assetId,
  required String name,
  required int totalQuantity,

  String? note,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => EditAssetOverlay(
      classId: classId,
      assetId: assetId,
      initialName: name,
      initialQuantity: totalQuantity,
      initialNote: note,
    ),
  );
}

class EditAssetOverlay extends ConsumerStatefulWidget {
  final String classId;
  final String assetId;
  final String initialName;
  final int initialQuantity;
  final String? initialNote;

  const EditAssetOverlay({
    super.key,
    required this.classId,
    required this.assetId,
    required this.initialName,
    required this.initialQuantity,
    this.initialNote,
  });

  @override
  ConsumerState<EditAssetOverlay> createState() => _EditAssetOverlayState();
}

class _EditAssetOverlayState extends ConsumerState<EditAssetOverlay> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _noteController;


  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.initialName);
    _quantityController =
        TextEditingController(text: widget.initialQuantity.toString());
    _noteController =
        TextEditingController(text: widget.initialNote ?? '');

  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Vui lòng nhập tên tài sản';
    }
    if (v.trim().length < 3) {
      return 'Tên tài sản tối thiểu 3 ký tự';
    }
    return null;
  }

  String? _validateQuantity(String? v) {
    final q = int.tryParse(v ?? '');
    if (q == null || q <= 0) {
      return 'Số lượng phải lớn hơn 0';
    }
    return null;
  }

  String? _validateNote(String? v) {
    if (v != null && v.length > 200) {
      return 'Ghi chú tối đa 200 ký tự';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      await ref.read(assetRepositoryProvider).updateAsset(
            assetId: widget.assetId,
            name: _nameController.text.trim(),
            totalQuantity: int.parse(_quantityController.text),
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );

      ref.invalidate(assetListWithStatusProvider(widget.classId));
      ref.invalidate(assetSummaryProvider(widget.classId));

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật tài sản: $e')),
      );
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
                  'Chỉnh sửa tài sản',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                const Text('Tên tài sản'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  validator: _validateName,
                  decoration: _inputDecoration(),
                ),

                const SizedBox(height: 16),

                const Text('Số lượng'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  validator: _validateQuantity,
                  decoration: _inputDecoration(),
                ),

                const SizedBox(height: 16),

                const Text('Ghi chú'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _noteController,
                  maxLines: 2,
                  validator: _validateNote,
                  decoration: _inputDecoration(),
                ),

                const SizedBox(height: 24),

                /// ===== ACTIONS (GIỮ STYLE CŨ) =====
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 45,
                        child: TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor:
                                const Color(0xFFF5F5F5),
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
                          onPressed:
                              _isSubmitting ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF155DFC),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Lưu thay đổi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w400,
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
