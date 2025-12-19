import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // [1] Import Riverpod
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/auth/presentation/views/login_register_screen.dart';
import '../../features/classes/presentation/views/classroom_page_screen.dart';
import '../../features/auth/presentation/view_models/auth_view_model.dart'; // [2] Import ViewModel
import '../../features/auth/data/repositories/auth_repository.dart'; // [3] Import Repo để lấy User info

// [4] Đổi thành ConsumerWidget để lắng nghe dữ liệu
class AppMenuDrawer extends ConsumerWidget {
  final bool isOwner;

  const AppMenuDrawer({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // [5] Lấy thông tin User hiện tại từ Supabase
    final authRepo = ref.watch(authRepositoryProvider);
    final user = authRepo.currentUser;
    
    // Lấy tên từ metadata (lúc đăng ký mình đã lưu vào key 'full_name')
    final String fullName = user?.userMetadata?['full_name'] ?? "Người dùng";
    final String email = user?.email ?? "Chưa cập nhật email";
    final String avatarChar = fullName.isNotEmpty ? fullName[0].toUpperCase() : "U";

    // Màu sắc badge
    final badgeColor = isOwner ? const Color(0xFFFEF3C7) : const Color(0xFFF3E8FF);
    final badgeTextColor = isOwner ? const Color(0xFFD97706) : const Color(0xFF9333EA);
    final roleText = isOwner ? "Lớp trưởng" : "Thành viên";
    
    // Dữ liệu giả lập lớp học (Phần này sẽ sửa sau khi có DB Lớp học)
    final className = isOwner ? "Lớp CNTT K20" : "Lớp Toán K20";
    final classCode = isOwner ? "KTF742" : "AHUJ98";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // 1. Header (Màu tím gradient + User Info THẬT)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF9333EA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Menu", style: GoogleFonts.roboto(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(LucideIcons.x, color: Colors.white),
                    )
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
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        // [6] Hiển thị ký tự đầu của tên thật
                        child: Text(avatarChar, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // [7] Hiển thị Tên thật
                            Text(fullName, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                            // [8] Hiển thị Email thật
                            Text(email, style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // 2. Nội dung chính
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text("LỚP HỌC HIỆN TẠI", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(className, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                            child: Text(roleText, style: GoogleFonts.roboto(color: badgeTextColor, fontSize: 10, fontWeight: FontWeight.bold)),
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.withOpacity(0.2))
                        ),
                        child: Text(classCode, style: GoogleFonts.roboto(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                      
                      if (isOwner) ...[
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.userPlus, size: 16),
                            label: const Text("Mời thành viên mới"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        )
                      ]
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text("TÀI KHOẢN", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _buildMenuItem(
                  icon: LucideIcons.arrowLeftRight,
                  title: "Đổi lớp học",
                  subtitle: "Chuyển sang lớp học khác",
                  onTap: () {
                     Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (_) => const ClassroomPageScreen()),
                       (route) => false
                     );
                  },
                ),

                const SizedBox(height: 12),

                // [9] Nút Đăng xuất - Cập nhật Logic
                _buildMenuItem(
                  icon: LucideIcons.logOut,
                  title: "Đăng xuất",
                  subtitle: "Thoát khỏi tài khoản",
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  isDestructive: true,
                  onTap: () async {
                     // Gọi hàm signOut từ ViewModel
                     await ref.read(authViewModelProvider.notifier).signOut();
                     
                     // Điều hướng về màn hình Login
                     if (context.mounted) {
                       Navigator.of(context).pushAndRemoveUntil(
                         MaterialPageRoute(builder: (_) => const LoginRegisterScreen()), 
                         (route) => false
                       );
                     }
                  },
                ),
              ],
            ),
          ),

          // 3. Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Divider(),
                const SizedBox(height: 12),
                Text("ClassPal", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Lớp trưởng 4.0 • Phiên bản 1.0", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
              ],
            ),
          )
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
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                  Text(subtitle, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 11)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}