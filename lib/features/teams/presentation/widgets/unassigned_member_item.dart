import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/team_models.dart';

class UnassignedMemberItem extends StatelessWidget {
  final TeamMember member;
  final bool isEditable;

  const UnassignedMemberItem({super.key, required this.member, this.isEditable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(member.name.substring(0, 1), style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(member.email, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (isEditable)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                minimumSize: const Size(0, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text("Phân tổ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }
}