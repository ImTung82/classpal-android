import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/team_model.dart';

class TeamMemberItem extends StatelessWidget {
  final TeamMember member;
  final bool isEditable;
  final VoidCallback? onRemove;
  // Callbacks cho chức tổ trưởng
  final VoidCallback? onPromote;
  final VoidCallback? onDemote;

  const TeamMemberItem({
    super.key,
    required this.member,
    this.isEditable = false,
    this.onRemove,
    this.onPromote,
    this.onDemote,
  });

  @override
  Widget build(BuildContext context) {
    // Style Leader: Viền vàng cam
    final isLeader = member.isLeader;
    final borderColor = isLeader
        ? Colors.orange.withOpacity(0.6)
        : Colors.grey.shade100;
    final borderWidth = isLeader ? 1.5 : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
        // Shadow nhẹ cho leader
        boxShadow: isLeader
            ? [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // 1. Avatar + Star
          Stack(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Color(int.parse(member.avatarColor)),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  member.name.substring(0, 1),
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              // [MỚI] Ngôi sao nhỏ
              if (isLeader)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.orange,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),

          // 2. Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        member.name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // [MỚI] Badge Text
                    if (isLeader) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Tổ trưởng",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.deepOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  member.email,
                  style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),

          // 3. Menu (Chỉ Owner mới thấy)
          if (isEditable)
            PopupMenuButton<String>(
              icon: const Icon(
                LucideIcons.moreHorizontal,
                size: 18,
                color: Colors.grey,
              ),
              onSelected: (value) {
                if (value == 'promote') onPromote?.call();
                if (value == 'demote') onDemote?.call();
                if (value == 'remove') onRemove?.call();
              },
              itemBuilder: (context) => [
                if (!isLeader)
                  PopupMenuItem(
                    value: 'promote',
                    child: Row(
                      children: const [
                        Icon(LucideIcons.star, size: 18, color: Colors.orange),
                        SizedBox(width: 8),
                        Text("Thăng làm Tổ trưởng"),
                      ],
                    ),
                  )
                else
                  PopupMenuItem(
                    value: 'demote',
                    child: Row(
                      children: const [
                        Icon(
                          LucideIcons.userMinus,
                          size: 18,
                          color: Colors.grey,
                        ),
                        SizedBox(width: 8),
                        Text("Gỡ chức Tổ trưởng"),
                      ],
                    ),
                  ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: const [
                      Icon(LucideIcons.trash2, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text("Xóa khỏi tổ", style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
