import 'package:flutter/material.dart';

// Đổi tên Class thành LoginRegisterScreen cho dễ hiểu
class LoginRegisterScreen extends StatefulWidget {
  const LoginRegisterScreen({super.key});

  @override
  State<LoginRegisterScreen> createState() => _LoginRegisterScreenState();
}

class _LoginRegisterScreenState extends State<LoginRegisterScreen> {
  // Trạng thái: true = Đăng nhập, false = Đăng ký
  bool isLogin = true;
  bool _obscureText = true;

  // Các Controller để quản lý text nhập vào
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  // Màu gradient chủ đạo
  final List<Color> gradientColors = const [
    Color(0xFF4A84F8), // Xanh dương
    Color(0xFF9D53F7), // Tím
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
            
            // --- 1. Phần Header (Logo & Tên App) ---
            _buildHeader(),

            const SizedBox(height: 30),

            // --- 2. Phần Card trắng chứa Form ---
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
                      // Thanh chuyển đổi Tab (Đăng nhập / Đăng ký)
                      _buildTabSwitcher(),
                      
                      const SizedBox(height: 30),

                      // Nội dung Form
                      // Nếu đang ở Tab Đăng ký thì hiện thêm ô "Họ và tên"
                      if (!isLogin) ...[
                        _buildLabel("Họ và tên"),
                        _buildTextField(
                          controller: _nameController,
                          hintText: "Nguyễn Văn A",
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 20),
                      ],

                      _buildLabel("Email"),
                      _buildTextField(
                        controller: _emailController,
                        hintText: "email@example.com",
                        icon: Icons.email_outlined,
                        inputType: TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),

                      _buildLabel("Mật khẩu"),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: "••••••••",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        isObscure: _obscureText,
                        onVisibilityToggle: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),

                      // Link Quên mật khẩu (Chỉ hiện ở Tab Đăng nhập)
                      if (isLogin) ...[
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(
                                color: Color(0xFF4A84F8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ] else 
                         const SizedBox(height: 30),

                      const SizedBox(height: 20),

                      // Nút Submit
                      _buildSubmitButton(),
                      
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

  // === Các Widget con (Helper Widgets) ===

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
              )
            ],
          ),
          child: const Icon(
            Icons.people_alt_outlined,
            size: 40,
            color: Color(0xFF4A84F8),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "ClassPal",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Lớp trưởng 4.0",
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTabItem(title: "Đăng nhập", isActive: isLogin, onTap: () => setState(() => isLogin = true)),
          _buildTabItem(title: "Đăng ký", isActive: !isLogin, onTap: () => setState(() => isLogin = false)),
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
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
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
      child: Text(
        text,
        style: const TextStyle(
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
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(icon, color: Colors.grey[400]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    color: Colors.grey[400],
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

  Widget _buildSubmitButton() {
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
        onPressed: () {
          if(isLogin) {
              print("Đang Đăng nhập: ${_emailController.text}");
          } else {
              print("Đang Đăng ký: ${_nameController.text}");
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          isLogin ? "Đăng nhập" : "Đăng ký",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}