import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/team_model.dart';

class AllMemberItem extends StatelessWidget {
  final TeamMember member;
  final String teamName;
  final int teamColor; // Màu của tổ để tô màu cho Tag
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AllMemberItem({
    super.key,
    required this.member,
    required this.teamName,
    required this.teamColor,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Màu tag sẽ nhạt hơn màu chính
    final tagColor = Color(teamColor);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // 1. Avatar
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Color(int.parse(member.avatarColor)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              member.name.substring(0, 1),
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const SizedBox(width: 12),

          // 2. Info (Tên, Email, Tag Tổ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(member.email, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                
                // Tag tên tổ
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: tagColor, // Hoặc tagColor.withOpacity(0.1) nếu muốn nền nhạt
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    teamName,
                    style: GoogleFonts.roboto(
                      color: Colors.white, // Hoặc tagColor nếu nền nhạt
                      fontSize: 10, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                )
              ],
            ),
          ),

          // 3. Actions (Edit / Delete)
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(LucideIcons.pencil, size: 18, color: Colors.grey),
                constraints: const BoxConstraints(), // Thu gọn vùng bấm
                padding: const EdgeInsets.all(8),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(8),
              ),
            ],
          )
        ],
      ),
    );
  }
}