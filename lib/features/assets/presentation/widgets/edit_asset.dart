import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


void showEditAssetOverlay(
  BuildContext context, {
  required String name,
  required String category,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) => EditAssetOverlay(
      initialName: name,
      initialCategory: category,
    ),
  );
}

class EditAssetOverlay extends StatefulWidget {
  final String initialName;
  final String initialCategory;

  const EditAssetOverlay({
    super.key,
    required this.initialName,
    required this.initialCategory,
  });

  @override
  State<EditAssetOverlay> createState() => _EditAssetOverlayState();
}

class _EditAssetOverlayState extends State<EditAssetOverlay> {
  late TextEditingController _nameController;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF155DFC),
          width: 1.2,
        ),
      ),
    );
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== TITLE =====
              Text(
                'Chỉnh sửa tài sản',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              /// ===== NAME =====
              const Text('Tên tài sản'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameController,
                decoration:
                    _inputDecoration(hint: 'VD: Remote Điều hòa'),
              ),

              const SizedBox(height: 16),

              /// ===== CATEGORY =====
              const Text('Danh mục'),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: const [
                  DropdownMenuItem(
                    value: 'Điện tử',
                    child: Text('Điện tử'),
                  ),
                  DropdownMenuItem(
                    value: 'Văn phòng phẩm',
                    child: Text('Văn phòng phẩm'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: _inputDecoration(),
              ),

              const SizedBox(height: 24),

              /// ===== ACTIONS =====
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
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
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: () {
                          
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF155DFC),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Lưu thay đổi',
                          style: TextStyle(fontSize: 16),
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
  }
}

