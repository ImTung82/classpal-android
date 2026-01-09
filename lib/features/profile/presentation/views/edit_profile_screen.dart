import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/profile_repository.dart';
import '../view_models/profile_view_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // State
  bool _isFetching = true;
  File? _pickedImage; // Ảnh chọn từ máy (File)
  String? _currentAvatarUrl; // URL ảnh từ server

  // Màu Gradient
  final List<Color> gradientColors = const [
    Color(0xFF4A84F8),
    Color(0xFF9D53F7),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 1. Load Data
  Future<void> _loadData() async {
    try {
      final data = await ref.read(profileRepositoryProvider).getProfile();

      if (mounted) {
        setState(() {
          _nameController.text = data['full_name'] ?? '';
          _phoneController.text = data['phone_number'] ?? '';
          _currentAvatarUrl = data['avatar_url'];

          _emailController.text =
              Supabase.instance.client.auth.currentUser?.email ?? '';
          _isFetching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isFetching = false);
      // Fallback
      final user = Supabase.instance.client.auth.currentUser;
      _nameController.text = user?.userMetadata?['full_name'] ?? '';
    }
  }

  // 2. Chọn ảnh (Image Picker)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: 180,
          child: Column(
            children: [
              Text(
                "Cập nhật ảnh đại diện",
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIconBtn(LucideIcons.camera, "Chụp ảnh", () async {
                    final XFile? picked = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (picked != null)
                      setState(() => _pickedImage = File(picked.path));
                    if (context.mounted) Navigator.pop(ctx);
                  }),
                  _buildIconBtn(LucideIcons.image, "Thư viện", () async {
                    final XFile? picked = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (picked != null)
                      setState(() => _pickedImage = File(picked.path));
                    if (context.mounted) Navigator.pop(ctx);
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIconBtn(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: gradientColors[0], size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.roboto(fontSize: 14)),
        ],
      ),
    );
  }

  // 3. Lưu
  void _onSave() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(profileViewModelProvider.notifier)
          .updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            imageFile: _pickedImage, // Truyền file ảnh
          );

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
              content: Text('Cập nhật thành công!'),
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
    final state = ref.watch(profileViewModelProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Chỉnh sửa hồ sơ',
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
      body: _isFetching
          ? Center(child: CircularProgressIndicator(color: gradientColors[0]))
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildAvatarSection(),
                      const SizedBox(height: 40),

                      _buildLabel("Họ và tên"),
                      _buildModernTextField(
                        controller: _nameController,
                        icon: LucideIcons.user,
                        hintText: "Nhập họ và tên",
                        validator: (v) => v!.isEmpty ? "Cần nhập tên" : null,
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("Số điện thoại"),
                      _buildModernTextField(
                        controller: _phoneController,
                        icon: LucideIcons.phone,
                        hintText: "Nhập số điện thoại",
                        inputType: TextInputType.phone,
                      ),
                      const SizedBox(height: 24),

                      _buildLabel("Email (Không thể thay đổi)"),
                      _buildModernTextField(
                        controller: _emailController,
                        icon: LucideIcons.mail,
                        hintText: "Email",
                        readOnly: true,
                      ),

                      const SizedBox(height: 40),
                      _buildGradientButton(
                        text: "Lưu thay đổi",
                        isLoading: isLoading,
                        onPressed: _onSave,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildAvatarSection() {
    ImageProvider? imageProvider;
    // Ưu tiên: Ảnh mới chọn > Ảnh Server > Mặc định
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else if (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_currentAvatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withOpacity(0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFF5F7FA),
              backgroundImage: imageProvider,
              child: imageProvider == null
                  ? Text(
                      _nameController.text.isNotEmpty
                          ? _nameController.text[0].toUpperCase()
                          : 'U',
                      style: GoogleFonts.roboto(
                        fontSize: 48,
                        color: gradientColors[0],
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradientColors),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(
                  LucideIcons.camera,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildModernTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool readOnly = false,
    TextInputType? inputType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: readOnly ? Colors.grey[100] : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: readOnly
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: inputType,
        validator: validator,
        style: GoogleFonts.roboto(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: readOnly ? Colors.grey[600] : Colors.black87,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: readOnly
              ? const Color(0xFFEEEEEE)
              : const Color(0xFFF5F7FA),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 20,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 12),
            child: Icon(
              icon,
              color: readOnly
                  ? Colors.grey[400]
                  : const Color(0xFF4A84F8).withOpacity(0.7),
              size: 22,
            ),
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
