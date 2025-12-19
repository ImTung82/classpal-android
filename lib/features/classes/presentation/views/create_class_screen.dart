import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/class_view_model.dart';

class CreateClassScreen extends ConsumerStatefulWidget {
  const CreateClassScreen({super.key});

  @override
  ConsumerState<CreateClassScreen> createState() => _CreateClassScreenState();
}

class _CreateClassScreenState extends ConsumerState<CreateClassScreen> {
  final double kHorizontalPadding = 24.0;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController(); // [MỚI]
  final TextEditingController _descController = TextEditingController();
  
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _generatedCode;

  @override
  void initState() {
    super.initState();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    _generatedCode = String.fromCharCodes(Iterable.generate(
        6, (_) => chars.codeUnitAt(Random().nextInt(chars.length))));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _studentIdController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _handleCreateClass() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ref.read(classControllerProvider.notifier).createClass(
            name: _nameController.text.trim(),
            schoolName: _schoolController.text.trim(),
            code: _generatedCode,
            ownerStudentCode: _studentIdController.text.trim(), // [MỚI] Gửi mã SV
            description: _descController.text.trim(),
            onSuccess: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tạo lớp học thành công!'), backgroundColor: Colors.green),
              );
              Navigator.of(context).pop();
            },
            onError: (message) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message), backgroundColor: Colors.red),
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(classControllerProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF407CFF), Color(0xFFAE47FF)],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER (Giữ nguyên Style đẹp) ---
                Padding(
                  padding: EdgeInsets.fromLTRB(kHorizontalPadding, 10, kHorizontalPadding, 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Transform.translate(
                              offset: const Offset(-8, 0),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                            ),
                            const Text('Quay lại', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Tạo lớp học mới', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      const Text('Bạn sẽ là lớp trưởng của lớp học', style: TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.w400)),
                    ],
                  ),
                ),

                // --- BODY ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(kHorizontalPadding, 30, kHorizontalPadding, 50),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // 1. MÃ LỚP TỰ ĐỘNG
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3E8FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFAE47FF).withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.qr_code, color: Color(0xFFAE47FF)),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Mã lớp tự động:", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      Text(_generatedCode, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF59168B))),
                                    ],
                                  )
                                ],
                              ),
                            ),

                            // 2. TÊN LỚP
                            const Text('Tên lớp học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 10),
                            _buildCustomTextField(
                              controller: _nameController,
                              hint: 'VD: Lớp CNTT K36',
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 20),

                            // 3. TRƯỜNG HỌC
                            const Text('Trường học', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 10),
                            _buildCustomTextField(
                              controller: _schoolController,
                              hint: 'VD: Đại học Bách Khoa',
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 20),

                            // 4. [MỚI] MÃ SINH VIÊN (OWNER)
                            Row(
                              children: [
                                const Text('Mã Sinh Viên của bạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                                const SizedBox(width: 8),
                                Tooltip(
                                  message: "Mã này dùng để quản lý điểm danh",
                                  child: Icon(Icons.info_outline, size: 18, color: Colors.grey[400]),
                                )
                              ],
                            ),
                            const SizedBox(height: 10),
                            _buildCustomTextField(
                              controller: _studentIdController,
                              hint: 'VD: B20DCCN001',
                              isLoading: isLoading,
                              textCapitalization: TextCapitalization.characters,
                            ),
                            const SizedBox(height: 20),

                            // 5. MÔ TẢ
                            const Text('Mô tả (Không bắt buộc)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
                            const SizedBox(height: 10),
                            _buildCustomTextField(
                              controller: _descController,
                              hint: 'Mô tả ngắn về lớp...',
                              isLoading: isLoading,
                              isRequired: false,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 30),

                            // 6. INFO BOX
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Quyền lợi của Lớp trưởng', style: TextStyle(color: Color(0xFF1C398E), fontSize: 16, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 15),
                                  BenefitItem(text: 'Phân công nhiệm vụ trực nhật'),
                                  BenefitItem(text: 'Quản lý tài sản chung'),
                                  BenefitItem(text: 'Tạo sự kiện và theo dõi đăng ký'),
                                  BenefitItem(text: 'Quản lý quỹ lớp minh bạch'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),

                            // 7. BUTTON GRADIENT
                            Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF407CFF), Color(0xFFAE47FF)]),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: const Color(0xFF407CFF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleCreateClass,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: isLoading
                                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                    : const Text('Tạo lớp học', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget TextField dùng chung style
  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String hint,
    required bool isLoading,
    bool isRequired = true,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !isLoading,
      style: const TextStyle(fontSize: 16),
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      validator: isRequired
          ? (value) => (value == null || value.trim().isEmpty) ? 'Vui lòng nhập thông tin' : null
          : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA6ADBA)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFA6ADBA))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF407CFF), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
      ),
    );
  }
}

// Widget BenefitItem (Giữ nguyên)
class BenefitItem extends StatelessWidget {
  final String text;
  const BenefitItem({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF193CB8), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF193CB8), fontSize: 14, fontWeight: FontWeight.w500, height: 1.3))),
        ],
      ),
    );
  }
}