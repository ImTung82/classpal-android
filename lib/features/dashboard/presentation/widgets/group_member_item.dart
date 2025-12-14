import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/dashboard_models.dart';

class GroupMemberItem extends StatelessWidget {
  final GroupMemberData member;
  const GroupMemberItem({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(member.avatarColor));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Center(child: Text(member.name.substring(0, 1), style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 12),
          Text(member.name, style: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}