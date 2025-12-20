import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/profile_view_model.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

  final List<Color> gradientColors = const [
    Color(0xFF4A84F8),
    Color(0xFF9D53F7),
  ];

  @override
  void dispose() {
    _passController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onChangePassword() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(profileViewModelProvider.notifier)
          .changePassword(_passController.text);
      final state = ref.read(profileViewModelProvider);

      if (mounted) {
        if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${state.error}'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đổi mật khẩu thành công!'),
              backgroundColor: Color(0xFF00C853),
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(profileViewModelProvider).isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Đổi mật khẩu',
          style: GoogleFonts.roboto(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tạo mật khẩu mới mạnh hơn để bảo vệ tài khoản ClassPal của bạn.",
                  style: GoogleFonts.roboto(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),

                _buildLabel("Mật khẩu mới"),
                _buildPasswordField(
                  controller: _passController,
                  hintText: "Nhập mật khẩu mới (tối thiểu 6 ký tự)",
                  isObscure: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass),
                  validator: (v) =>
                      (v != null && v.length < 6) ? "Mật khẩu quá ngắn" : null,
                ),
                const SizedBox(height: 24),

                _buildLabel("Xác nhận mật khẩu"),
                _buildPasswordField(
                  controller: _confirmController,
                  hintText: "Nhập lại mật khẩu mới",
                  isObscure: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  validator: (v) =>
                      v != _passController.text ? "Mật khẩu không khớp" : null,
                ),
                const SizedBox(height: 40),

                _buildGradientButton(
                  text: "Xác nhận",
                  isLoading: isLoading,
                  onPressed: _onChangePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Widgets (Giữ nguyên style)
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isObscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        validator: validator,
        style: GoogleFonts.roboto(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFF5F7FA),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              LucideIcons.lock,
              color: const Color(0xFF4A84F8).withOpacity(0.7),
              size: 22,
            ),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              isObscure ? LucideIcons.eye : LucideIcons.eyeOff,
              color: Colors.grey[400],
              size: 20,
            ),
            onPressed: onToggle,
          ),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF4A84F8), width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required String text,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 2,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.roboto(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
