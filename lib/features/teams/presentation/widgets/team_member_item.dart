import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/team_model.dart';

class TeamMemberItem extends StatelessWidget {
  final TeamMember member;
  final bool isEditable;
  final VoidCallback? onRemove;

  const TeamMemberItem({
    super.key, 
    required this.member, 
    this.isEditable = false, 
    this.onRemove
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: Color(int.parse(member.avatarColor)),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              member.name.substring(0, 1),
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.roboto(fontWeight: FontWeight.w500, fontSize: 14, color: Colors.black87)),
                Text(member.email, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (isEditable)
            IconButton(
              icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
        ],
      ),
    );
  }
}