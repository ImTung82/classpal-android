import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../features/classes/data/models/class_model.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final ClassModel classModel;
  final String subtitle; // (Biến này có thể dùng làm tên màn hình con nếu cần, hiện tại mình ưu tiên hiển thị Tên Trường)
  final VoidCallback onMenuPressed;
  final bool showBackArrow;

  const AppHeader({
    super.key,
    required this.classModel,
    required this.subtitle,
    required this.onMenuPressed,
    this.showBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    // Logic: Màu sắc Role
    final isOwner = classModel.role == 'owner';
    final roleText = isOwner ? "Lớp trưởng" : "Thành viên";
    
    // Màu Badge (Lớp trưởng: Tím / Thành viên: Cam)
    final badgeColor = isOwner ? const Color(0xFF6A5AE0) : const Color(0xFFFF8A00);
    final badgeBgColor = isOwner ? const Color(0xFFF3E8FF) : const Color(0xFFFFF4E5);

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 5, // Căn chỉnh lại padding top chút cho cân
        left: 16,
        right: 16,
        bottom: 12
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // 1. NÚT BACK (Nếu có)
          if (showBackArrow)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.black87),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(), // Thu gọn vùng bấm để không chiếm chỗ
              ),
            ),
            
          // 2. THÔNG TIN LỚP HỌC (Tên Lớp + Tên Trường)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  classModel.name,
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w800, // Đậm hơn chút cho nổi bật
                    fontSize: 18, 
                    color: Colors.black87
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Hiển thị Tên trường (Nếu có), nếu không thì hiển thị subtitle (Tên màn hình)
                Text(
                  (classModel.schoolName != null && classModel.schoolName!.isNotEmpty)
                      ? classModel.schoolName!
                      : subtitle, 
                  style: GoogleFonts.roboto(
                    color: Colors.grey[500], 
                    fontSize: 13,
                    fontWeight: FontWeight.w500
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // 3. ACTIONS (Badge Role + Thông báo + Menu)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Badge Role
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withOpacity(0.2)),
                ),
                child: Text(
                  roleText,
                  style: GoogleFonts.roboto(
                    color: badgeColor, 
                    fontSize: 11, 
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Nút Thông báo (Mới thêm)
              IconButton(
                icon: const Icon(LucideIcons.bell, size: 22, color: Colors.black54),
                onPressed: () {
                  // TODO: Mở màn hình thông báo
                },
                constraints: const BoxConstraints(), // Thu gọn
                padding: const EdgeInsets.all(8),
              ),

              const SizedBox(width: 4),

              // Nút Menu
              IconButton(
                icon: const Icon(LucideIcons.menu, size: 24, color: Colors.black87),
                onPressed: onMenuPressed,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(75); // Điều chỉnh lại chiều cao cho vừa vặn
}