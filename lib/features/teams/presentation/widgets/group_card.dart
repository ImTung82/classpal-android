import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/team_model.dart';
import 'team_member_item.dart';

class GroupCard extends StatelessWidget {
  final TeamGroup group;
  final bool isEditable; 
  final Function(TeamGroup)? onEditGroup;
  final Function(TeamGroup)? onDeleteGroup;
  final Function(TeamMember)? onRemoveMember;

  const GroupCard({
    super.key, 
    required this.group, 
    this.isEditable = false,
    this.onEditGroup,
    this.onDeleteGroup,
    this.onRemoveMember,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(group.color); 

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // [STYLE] Bo góc mềm mại hơn
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)), // [STYLE] Shadow mềm hơn
        ],
      ),
      child: Column(
        children: [
          // === HEADER TỔ ===
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12), // Padding bên phải nhỏ hơn để chứa nút menu
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tên tổ
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.users, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Text(group.name, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17)),
                  ],
                ),
                
                // Actions
                Row(
                  children: [
                    // Badge số lượng
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                      child: Text("${group.members.length}", style: GoogleFonts.roboto(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                    ),
                    
                    if (isEditable) ...[
                      const SizedBox(width: 4),
                      // [MENU ĐẸP HƠN Ở ĐÂY]
                      _buildStylishPopupMenu(),
                    ]
                  ],
                )
              ],
            ),
          ),
          
          // === DANH SÁCH THÀNH VIÊN ===
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (group.members.isEmpty)
                   Padding(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     child: Column(
                       children: [
                         Icon(LucideIcons.userX, size: 32, color: Colors.grey.shade300),
                         const SizedBox(height: 8),
                         Text("Chưa có thành viên nào", style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey)),
                       ],
                     ),
                   )
                else
                  ...group.members.map((m) => TeamMemberItem(
                    member: m, 
                    isEditable: isEditable,
                    onRemove: () => onRemoveMember?.call(m), 
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Hàm tách riêng để xây dựng Menu đẹp
  Widget _buildStylishPopupMenu() {
    return PopupMenuButton<String>(
      // 1. Nút bấm đẹp hơn (Có nền mờ)
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15), // Nền mờ nhẹ
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.moreVertical, color: Colors.white, size: 18),
      ),
      borderRadius: BorderRadius.circular(16), // Bo góc menu popup
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.2),
      offset: const Offset(0, 45), // Đẩy menu xuống dưới nút bấm một chút
      
      onSelected: (value) {
        if (value == 'edit') onEditGroup?.call(group);
        if (value == 'delete') onDeleteGroup?.call(group);
      },
      itemBuilder: (context) => [
        // Item 1: Đổi tên
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(LucideIcons.edit3, size: 20, color: Colors.grey.shade700),
              const SizedBox(width: 12),
              Text("Đổi tên tổ", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: Colors.black87)),
            ],
          ),
        ),
        // Divider nhẹ
        const PopupMenuDivider(height: 1),
        // Item 2: Xóa (Màu đỏ cảnh báo)
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              const Icon(LucideIcons.trash2, size: 20, color: Color(0xFFEF4444)), // Màu đỏ
              const SizedBox(width: 12),
              Text("Xóa tổ này", style: GoogleFonts.roboto(fontWeight: FontWeight.w500, color: const Color(0xFFEF4444))),
            ],
          ),
        ),
      ],
    );
  }
}