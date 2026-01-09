import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/auth_view_model.dart';
import '../../../classes/presentation/views/classroom_page_screen.dart';
import '../../../profile/presentation/view_models/profile_view_model.dart';
import 'forgot_password_screen.dart';

class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  ConsumerState<LoginRegisterScreen> createState() =>
      _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();

  final List<Color> gradientColors = const [
    Color(0xFF4A84F8),
    Color(0xFF9D53F7),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _forgotEmailController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog(AuthViewModel vm) {
    // Tự động điền email nếu ở ngoài đã nhập
    if (_emailController.text.isNotEmpty) {
      _forgotEmailController.text = _emailController.text;
    }

    showDialog(
      context: context,
      barrierDismissible:
          false, // [CẬP NHẬT] Không cho đóng khi bấm ra ngoài để tránh lỗi logic khi đang loading
      builder: (ctx) {
        // Biến cục bộ lưu trạng thái lỗi
        String? errorText;
        // [CẬP NHẬT] Biến cục bộ lưu trạng thái loading của riêng Dialog
        bool isDialogLoading = false;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Icon trang trí
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A84F8).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          LucideIcons.lock,
                          color: Color(0xFF4A84F8),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Tiêu đề
                      Text(
                        "Lấy lại mật khẩu",
                        style: GoogleFonts.roboto(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Nội dung hướng dẫn
                      Text(
                        "Nhập email đã đăng ký của bạn, hệ thống sẽ gửi liên kết để đặt lại mật khẩu mới.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 4. Ô nhập liệu Email
                      TextField(
                        controller: _forgotEmailController,
                        keyboardType: TextInputType.emailAddress,
                        // Nếu đang loading thì disable input luôn
                        enabled: !isDialogLoading,
                        style: GoogleFonts.roboto(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "email@example.com",
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          errorText: errorText,
                          errorMaxLines: 2,
                          prefixIcon: Icon(
                            LucideIcons.mail,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A84F8),
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.0,
                            ),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          if (errorText != null) {
                            setStateDialog(() {
                              errorText = null;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 32),

                      // 5. Buttons (Hủy / Gửi)
                      Row(
                        children: [
                          // Nút Hủy
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                // Nếu đang loading thì không cho bấm Hủy (hoặc bạn có thể cho phép tùy ý)
                                onPressed: isDialogLoading
                                    ? null
                                    : () => Navigator.of(ctx).pop(),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  foregroundColor: Colors.black87,
                                ),
                                child: Text(
                                  "Hủy",
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Nút Gửi
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                // Disable nút khi đang loading
                                onPressed: isDialogLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();
                                        final email = _forgotEmailController
                                            .text
                                            .trim();

                                        if (email.isEmpty) {
                                          setStateDialog(() {
                                            errorText = "Vui lòng nhập email";
                                          });
                                          return;
                                        }

                                        // [CẬP NHẬT] Bắt đầu loading
                                        setStateDialog(() {
                                          isDialogLoading = true;
                                          errorText = null;
                                        });

                                        vm.sendPasswordReset(
                                          email: email,
                                          onSuccess: (msg) {
                                            // Đóng dialog khi thành công
                                            Navigator.of(ctx).pop();
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(msg),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          },
                                          onError: (err) {
                                            // [CẬP NHẬT] Tắt loading và hiện lỗi
                                            setStateDialog(() {
                                              isDialogLoading = false;
                                              errorText = err;
                                            });
                                          },
                                        );
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4A84F8),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  // Khi bị disable (đang loading), giữ nguyên độ mờ vừa phải
                                  disabledBackgroundColor: const Color(
                                    0xFF4A84F8,
                                  ).withOpacity(0.6),
                                  disabledForegroundColor: Colors.white,
                                ),
                                // [CẬP NHẬT] Hiển thị Loading Indicator hoặc Text
                                child: isDialogLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        "Gửi yêu cầu",
                                        style: GoogleFonts.roboto(
                                          fontWeight: FontWeight.bold,
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
            );
          },
        );
      },
    ).then((_) {
      _forgotEmailController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.isRecoveryMode && (previous?.isRecoveryMode == false)) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final authViewModel = ref.read(authViewModelProvider.notifier);

    final isLogin = authState.isLoginMode;
    final isObscure = !authState.isPasswordVisible;
    final isLoading = authState.isLoading;

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 30),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabSwitcher(isLogin, authViewModel),
                        const SizedBox(height: 30),

                        if (!isLogin) ...[
                          _buildLabel("Họ và tên"),
                          _buildTextField(
                            controller: _nameController,
                            hintText: "Nguyễn Văn A",
                            icon: LucideIcons.user,
                          ),
                          const SizedBox(height: 20),

                          _buildLabel("Số điện thoại"),
                          _buildTextField(
                            controller: _phoneController,
                            hintText: "0912345678",
                            icon: LucideIcons.phone,
                            inputType: TextInputType.phone,
                          ),
                          const SizedBox(height: 20),
                        ],

                        _buildLabel("Email"),
                        _buildTextField(
                          controller: _emailController,
                          hintText: "email@example.com",
                          icon: LucideIcons.mail,
                          inputType: TextInputType.emailAddress,
                        ),

                        const SizedBox(height: 20),

                        _buildLabel("Mật khẩu"),
                        _buildTextField(
                          controller: _passwordController,
                          hintText: "••••••••",
                          icon: LucideIcons.lock,
                          isPassword: true,
                          isObscure: isObscure,
                          onVisibilityToggle: () =>
                              authViewModel.togglePasswordVisibility(),
                        ),

                        if (isLogin) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  _showForgotPasswordDialog(authViewModel),
                              child: Text(
                                "Quên mật khẩu?",
                                style: GoogleFonts.roboto(
                                  color: const Color(0xFF4A84F8),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ] else
                          const SizedBox(height: 30),

                        const SizedBox(height: 20),

                        _buildSubmitButton(isLogin, isLoading, authViewModel),

                        const SizedBox(height: 20),
                      ],
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

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            LucideIcons.users,
            size: 40,
            color: Color(0xFF4A84F8),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "ClassPal",
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Lớp trưởng 4.0",
          style: GoogleFonts.roboto(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher(bool isLogin, AuthViewModel vm) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: isLogin ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              _buildSlidingTabItem(
                title: "Đăng nhập",
                isSelected: isLogin,
                onTap: () => isLogin ? null : vm.toggleAuthMode(),
              ),
              _buildSlidingTabItem(
                title: "Đăng ký",
                isSelected: !isLogin,
                onTap: () => !isLogin ? null : vm.toggleAuthMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingTabItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.translucent,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: GoogleFonts.roboto(
              color: isSelected ? Colors.black : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool isPassword = false,
    bool isObscure = false,
    VoidCallback? onVisibilityToggle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? isObscure : false,
        keyboardType: inputType,
        style: GoogleFonts.roboto(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? LucideIcons.eye : LucideIcons.eyeOff,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                  onPressed: onVisibilityToggle,
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A84F8)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool isLogin, bool isLoading, AuthViewModel vm) {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(colors: gradientColors),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                vm.submit(
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                  name: isLogin ? null : _nameController.text.trim(),
                  phone: isLogin ? null : _phoneController.text.trim(),
                  onSuccess: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: Colors.green,
                      ),
                    );

                    if (isLogin) {
                      // Invalidate profile provider để fetch lại dữ liệu mới
                      ref.invalidate(currentProfileProvider);
                      
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const ClassroomPageScreen(),
                        ),
                        (route) => false,
                      );
                    } else {
                      vm.toggleAuthMode();
                      _passwordController.clear();
                    }
                  },
                  onError: (err) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err), backgroundColor: Colors.red),
                    );
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                isLogin ? "Đăng nhập" : "Đăng ký",
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
