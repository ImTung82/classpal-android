import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart'; // Import Lucide
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts
import '../view_models/auth_view_model.dart';
import '../views/classroom_page_screen.dart';
class LoginRegisterScreen extends ConsumerStatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  ConsumerState<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends ConsumerState<LoginRegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  final List<Color> gradientColors = const [
    Color(0xFF4A84F8),
    Color(0xFF9D53F7),
  ];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe state
    final authState = ref.watch(authViewModelProvider);
    // Lấy notifier để gọi hàm
    final authViewModel = ref.read(authViewModelProvider.notifier);

    final isLogin = authState.isLoginMode;
    final isObscure = !authState.isPasswordVisible;
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Container(
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
                          icon: LucideIcons.user, // Dùng Lucide Icon
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildLabel("Email"),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "email@example.com",
                        icon: LucideIcons.mail, // Dùng Lucide Icon
                        inputType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      _buildLabel("Mật khẩu"),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "••••••••",
                        icon: LucideIcons.lock, // Dùng Lucide Icon
                        isPassword: true,
                        isObscure: isObscure,
                        onVisibilityToggle: () => authViewModel.togglePasswordVisibility(),
                      ),

                      if (isLogin) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(
                              "Quên mật khẩu?",
                              style: GoogleFonts.roboto( // Dùng Google Fonts
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
    );
  }

  // --- Helper Widgets ---

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
            ],
          ),
          child: const Icon(LucideIcons.users, size: 40, color: Color(0xFF4A84F8)), // Icon Lucide
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _buildTabItem(title: "Đăng nhập", isActive: isLogin, onTap: () => isLogin ? null : vm.toggleAuthMode()),
          _buildTabItem(title: "Đăng ký", isActive: !isLogin, onTap: () => !isLogin ? null : vm.toggleAuthMode()),
        ],
      ),
    );
  }

  Widget _buildTabItem({required String title, required bool isActive, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.roboto(
              color: isActive ? Colors.black : Colors.grey[600],
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
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
                  icon: Icon(isObscure ? LucideIcons.eye : LucideIcons.eyeOff, color: Colors.grey[400], size: 20),
                  onPressed: onVisibilityToggle,
                )
              : null,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[400]),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A84F8))),
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
        boxShadow: [BoxShadow(color: gradientColors[0].withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ElevatedButton(
        onPressed: isLoading
            ? null
            : () {
                vm.submit(
                  email: _emailController.text,
                  password: _passwordController.text,
                  name: isLogin ? null : _nameController.text,
                  onSuccess: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.green));
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => const ClassroomPageScreen(),
                      ),
                    );
                  },
                  onError: (err) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err), backgroundColor: Colors.red));
                  },
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                isLogin ? "Đăng nhập" : "Đăng ký",
                style: GoogleFonts.roboto(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}