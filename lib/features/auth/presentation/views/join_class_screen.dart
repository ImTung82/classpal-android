import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/join_class_view_model.dart';

class JoinClassScreen extends ConsumerStatefulWidget {
  const JoinClassScreen({super.key});

  @override
  ConsumerState<JoinClassScreen> createState() => _JoinClassScreenState();
}

class _JoinClassScreenState extends ConsumerState<JoinClassScreen> {
  final TextEditingController _codeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleJoinClass() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      ref
          .read(joinClassViewModelProvider.notifier)
          .joinClass(
            code: _codeController.text,
            onSuccess: () {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tham gia lớp học thành công!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context); // Quay về màn hình trước
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
    final state = ref.watch(joinClassViewModelProvider);
    final isLoading = state.isLoading;
    final double kHorizontalPadding = 24.0;

    return Scaffold(
      // Chống tràn màn hình khi bàn phím hiện lên
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF407CFF), Color(0xFFAE47FF)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Padding(
                padding: EdgeInsets.fromLTRB(
                  kHorizontalPadding,
                  10,
                  kHorizontalPadding,
                  20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Transform.translate(
                            offset: const Offset(-8, 0),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const Text(
                            'Quay lại',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Tham gia lớp học',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nhập mã lớp học từ lớp trưởng',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              // --- BODY ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      kHorizontalPadding,
                      30,
                      kHorizontalPadding,
                      50,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mã lớp học',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // TEXT FIELD NHẬP MÃ
                          TextFormField(
                            controller: _codeController,
                            enabled: !isLoading,
                            maxLength: 6,
                            textCapitalization: TextCapitalization.characters,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Vui lòng nhập mã lớp';
                              }
                              if (value.trim().length != 6) {
                                return 'Mã lớp phải đủ 6 ký tự';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              counterText: "",
                              hintText: 'VD: ABC123',
                              hintStyle: const TextStyle(
                                color: Color(0xFFA6ADBA),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFA6ADBA),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFF407CFF),
                                  width: 1.5,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.red,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhập mã 6 ký tự được cung cấp',
                            style: TextStyle(
                              color: Colors.black.withOpacity(0.5),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // INFO BOX (QUYỀN LỢI)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFAF5FF,
                              ), // Màu nền tím nhạt như thiết kế
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Làm thành viên lớp',
                                  style: TextStyle(
                                    color: Color(0xFF59168B),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 15),
                                _BenefitRow(text: 'Xem nhiệm vụ được giao'),
                                _BenefitRow(text: 'Đăng ký sự kiện dễ dàng'),
                                _BenefitRow(text: 'Mượn/trả tài sản chung'),
                                _BenefitRow(text: 'Theo dõi quỹ lớp minh bạch'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // BUTTON
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF407CFF), Color(0xFFAE47FF)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF407CFF,
                                  ).withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _handleJoinClass,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Tham gia lớp học',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
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
    );
  }
}

// Widget nhỏ hiển thị dòng quyền lợi
class _BenefitRow extends StatelessWidget {
  final String text;
  const _BenefitRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          // Icon giả lập ô vuông nhỏ trong thiết kế Figma, ở đây dùng Icon Check cho đẹp
          const Icon(Icons.check_circle, size: 20, color: Color(0xFF6E11B1)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6E11B1),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
