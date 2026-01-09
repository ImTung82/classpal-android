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

// [IMPORT PROFILE]
import '../../features/profile/presentation/views/edit_profile_screen.dart';
import '../../features/profile/presentation/views/change_password_screen.dart';
import '../../features/profile/presentation/view_models/profile_view_model.dart'; // Import view model mới

class AppMenuDrawer extends ConsumerWidget {
  final ClassModel? classModel;

  const AppMenuDrawer({super.key, this.classModel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy thông tin User từ Auth (Backup)
    final authRepo = ref.watch(authRepositoryProvider);
    final authUser = authRepo.currentUser;

    // 2. Lắng nghe dữ liệu Profile từ Database (Ưu tiên)
    final profileAsync = ref.watch(currentProfileProvider);
    final profileData = profileAsync.hasValue ? profileAsync.value : null;

    // Logic ưu tiên: Dữ liệu DB > Dữ liệu Auth
    final String fullName =
        profileData?['full_name'] ??
        authUser?.userMetadata?['full_name'] ??
        "Người dùng";

    final String email = authUser?.email ?? "Chưa cập nhật email";
    final String avatarChar = fullName.isNotEmpty
        ? fullName[0].toUpperCase()
        : "U";

    // Lấy URL Avatar
    final String? avatarUrl = profileData?['avatar_url'];

    // Logic hiển thị thông tin lớp (Giữ nguyên)
    final bool isInClass = classModel != null;
    final bool isOwner = isInClass && classModel!.role == 'owner';
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
                      // [CẬP NHẬT] Phần hiển thị Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                          // Nếu có ảnh thì hiển thị ảnh nền
                          image: avatarUrl != null && avatarUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(avatarUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        alignment: Alignment.center,
                        // Nếu KHÔNG có ảnh thì hiển thị chữ cái
                        child: (avatarUrl == null || avatarUrl.isEmpty)
                            ? Text(
                                avatarChar,
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),

                      // Thông tin tên & email
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

          // 2. NỘI DUNG CHÍNH (Giữ nguyên phần dưới)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ... (Phần logic lớp học giữ nguyên như cũ)
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
                  // ... Copy lại đoạn hiển thị Class Info từ file cũ vào đây
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
                        // ... Copy tiếp các phần hiển thị mã lớp, mã sv ...
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // [SECTION TÀI KHOẢN] (Giữ nguyên)
                Text(
                  "TÀI KHOẢN",
                  style: GoogleFonts.roboto(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

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

                _buildMenuItem(
                  icon: LucideIcons.user,
                  title: "Hồ sơ cá nhân",
                  subtitle: "Chỉnh sửa thông tin",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                // ... Các menu item còn lại giữ nguyên
                const SizedBox(height: 12),
                _buildMenuItem(
                  icon: LucideIcons.lock,
                  title: "Đổi mật khẩu",
                  subtitle: "Cập nhật mật khẩu mới",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ChangePasswordScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
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

          // 3. FOOTER (Giữ nguyên)
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
