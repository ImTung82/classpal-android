import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Tên lớp
  final String subtitle; // Role (Lớp trưởng/Thành viên)
  final VoidCallback onMenuPressed;
  final bool showBackArrow; // Thêm tùy chọn hiện nút Back cho các màn con

  const AppHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onMenuPressed,
    this.showBackArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))), // Thêm viền nhẹ dưới
      ),
      child: Row(
        children: [
          // Logic: Nếu showBackArrow = true thì hiện nút back, ngược lại hiện Logo
          if (showBackArrow)
            IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            )
          else
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFA855F7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(LucideIcons.crown, color: Colors.white, size: 20),
            ),
            
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.roboto(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          
          IconButton(
            icon: const Icon(LucideIcons.menu, color: Colors.black87),
            onPressed: onMenuPressed,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}