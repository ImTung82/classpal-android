import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({
    super.key, 
    required this.currentIndex, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // List menu item này nên cố định cho toàn app
    final items = [
      {'icon': LucideIcons.home, 'label': 'Trang chủ'},
      {'icon': LucideIcons.users, 'label': 'Đội nhóm'},
      {'icon': LucideIcons.clipboardList, 'label': 'Trực nhật'},
      {'icon': LucideIcons.box, 'label': 'Tài sản'},
      {'icon': LucideIcons.calendar, 'label': 'Sự kiện'},
      {'icon': LucideIcons.dollarSign, 'label': 'Quỹ lớp'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 10, 
            offset: const Offset(0, -4)
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = currentIndex == index;
          final color = isSelected ? const Color(0xFF4A84F8) : Colors.grey[400];
          
          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(items[index]['icon'] as IconData, size: 24, color: color),
                const SizedBox(height: 4),
                Text(
                  items[index]['label'] as String,
                  style: GoogleFonts.roboto(
                    fontSize: 10, 
                    color: color, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}