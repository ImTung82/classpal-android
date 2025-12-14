import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/auth/presentation/views/classroom_page_screen.dart'; // Để điều hướng khi đổi lớp/logout

class AppMenuDrawer extends StatelessWidget {
  final bool isOwner; // Biến quyết định giao diện Lớp trưởng hay Thành viên

  const AppMenuDrawer({super.key, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    // Màu sắc badge dựa trên role
    final badgeColor = isOwner ? const Color(0xFFFEF3C7) : const Color(0xFFF3E8FF);
    final badgeTextColor = isOwner ? const Color(0xFFD97706) : const Color(0xFF9333EA);
    final roleText = isOwner ? "Lớp trưởng" : "Thành viên";
    
    // Dữ liệu giả lập
    final className = isOwner ? "Lớp CNTT K20" : "Lớp Toán K20";
    final classCode = isOwner ? "KTF742" : "AHUJ98";

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, // Chiếm 85% màn hình
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(0), bottomLeft: Radius.circular(0)),
      ),
      child: Column(
        children: [
          // 1. Header (Màu tím gradient + User Info)
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3B82F6), Color(0xFF9333EA)], // Blue -> Purple
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                // Hàng tiêu đề Menu + Nút đóng
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
                
                // Card User Info (Trong suốt mờ)
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
                        child: Text("NV", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Nguyễn Văn A", style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("mail@example.com", style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),

          // 2. Nội dung chính (Scrollable)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // --- Section: Lớp học hiện tại ---
                Text("LỚP HỌC HIỆN TẠI", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF).withOpacity(0.5), // Xanh rất nhạt
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
                      
                      // Nút mời thành viên (Chỉ hiện cho Lớp trưởng)
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

                // --- Section: Tài khoản ---
                Text("TÀI KHOẢN", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                // Nút Đổi lớp học
                _buildMenuItem(
                  icon: LucideIcons.arrowLeftRight,
                  title: "Đổi lớp học",
                  subtitle: "Chuyển sang lớp học khác",
                  onTap: () {
                     // Quay về màn hình chọn lớp
                     Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (_) => const ClassroomPageScreen()),
                       (route) => false
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
                  onTap: () {
                     // Logic Logout sau này
                     Navigator.of(context).pushAndRemoveUntil(
                       MaterialPageRoute(builder: (_) => const ClassroomPageScreen()), // Tạm thời về chọn lớp
                       (route) => false
                     );
                  },
                ),
              ],
            ),
          ),

          // 3. Footer (Version info)
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

  // Widget con cho các mục menu
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