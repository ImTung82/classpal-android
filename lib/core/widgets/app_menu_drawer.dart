import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// [IMPORT AUTH & CLASS]
import '../../features/auth/presentation/views/login_register_screen.dart';
import '../../features/classes/presentation/views/classroom_page_screen.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/classes/data/models/class_model.dart';

// [IMPORT PROFILE - MỚI]
import '../../features/profile/presentation/views/edit_profile_screen.dart';
import '../../features/profile/presentation/views/change_password_screen.dart';

class AppMenuDrawer extends ConsumerWidget {
  final ClassModel?
  classModel; // Có thể null (nếu đang ở màn hình danh sách lớp)

  const AppMenuDrawer({super.key, this.classModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy thông tin User
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;

    final String fullName = user?.userMetadata?['full_name'] ?? "Người dùng";
    final String email = user?.email ?? "Chưa cập nhật email";
    final String avatarChar = fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : "U";

    // 2. Logic hiển thị thông tin lớp (nếu có)
    final bool isInClass = classModel != null;
    final bool isOwner = isInClass && classModel!.role == 'owner';

    // Màu sắc Role
    final badgeColor = isOwner
        ? const Color(0xFF6A5AE0)
        : const Color(0xFFFF8A00);
    final badgeBgColor = isOwner
        ? const Color(0xFFF3E8FF)
        : const Color(0xFFFFF4E5);
    final roleText = isOwner ? "Lớp trưởng" : "Thành viên";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          bottomLeft: Radius.circular(0),
        ),
      ),
      child: Column(
        children: [
          // 1. HEADER USER (Gradient Tím ClassPal)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A5AE0), Color(0xFF8F7CFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Menu",
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Card User Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          avatarChar,
                          style: GoogleFonts.roboto(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fullName,
                              style: GoogleFonts.roboto(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              email,
                              style: GoogleFonts.roboto(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. NỘI DUNG CHÍNH
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // [SECTION LỚP HỌC - CHỈ HIỆN KHI ĐANG TRONG LỚP]
                if (isInClass) ...[
                  Text(
                    "LỚP HỌC HIỆN TẠI",
                    style: GoogleFonts.roboto(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8FC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hàng 1: Tên Lớp + Badge Role
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                classModel!.name,
                                style: GoogleFonts.roboto(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: badgeBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: badgeColor.withOpacity(0.2),
                                ),
                              ),
                              child: Text(
                                roleText,
                                style: GoogleFonts.roboto(
                                  color: badgeColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Hàng 2: Tên Trường (Nếu có)
                        if (classModel!.schoolName != null &&
                            classModel!.schoolName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                LucideIcons.school,
                                size: 14,
                                color: Colors.grey[500],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  classModel!.schoolName!,
                                  style: GoogleFonts.roboto(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 12),

                        // Hàng 3: Mã lớp
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFF6A5AE0).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Mã lớp: ",
                                style: GoogleFonts.roboto(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              SelectableText(
                                classModel!.code,
                                style: GoogleFonts.roboto(
                                  color: const Color(0xFF6A5AE0),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // [SECTION TÀI KHOẢN]
                Text(
                  "TÀI KHOẢN",
                  style: GoogleFonts.roboto(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                // Nút Đổi lớp / Danh sách lớp
                _buildMenuItem(
                  icon: LucideIcons.arrowLeftRight,
                  title: isInClass ? "Đổi lớp học" : "Danh sách lớp học",
                  subtitle: isInClass
                      ? "Chuyển sang lớp học khác"
                      : "Về màn hình chính",
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const ClassroomPageScreen(),
                      ),
                      (route) => false,
                    );
                  },
                ),

                const SizedBox(height: 12),

                // [MỚI] Nút Hồ sơ cá nhân
                _buildMenuItem(
                  icon: LucideIcons.user,
                  title: "Hồ sơ cá nhân",
                  subtitle: "Chỉnh sửa thông tin",
                  onTap: () {
                    Navigator.pop(context); // Đóng drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // [MỚI] Nút Đổi mật khẩu
                _buildMenuItem(
                  icon: LucideIcons.lock,
                  title: "Đổi mật khẩu",
                  subtitle: "Cập nhật mật khẩu mới",
                  onTap: () {
                    Navigator.pop(context); // Đóng drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Nút Đăng xuất
                _buildMenuItem(
                  icon: LucideIcons.logOut,
                  title: "Đăng xuất",
                  subtitle: "Thoát khỏi tài khoản",
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  isDestructive: true,
                  onTap: () async {
                    await ref.read(authViewModelProvider.notifier).signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const LoginRegisterScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          // 3. FOOTER
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.graduationCap,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "ClassPal",
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Lớp trưởng 4.0 • Phiên bản 1.0",
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.grey,
    Color textColor = Colors.black,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.roboto(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 18, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
