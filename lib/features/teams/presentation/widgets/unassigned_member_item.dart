import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/team_model.dart';

class UnassignedMemberItem extends StatelessWidget {
  final TeamMember member;
  final bool isEditable;
  // Callback khi bấm nút "Phân tổ"
  final VoidCallback? onAssign; 

  const UnassignedMemberItem({
    super.key, 
    required this.member, 
    this.isEditable = false,
    this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: Color(0xFFD1D5DB), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(
              member.name.isNotEmpty ? member.name.substring(0, 1) : "?", 
              style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.name, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(member.email, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),

          // Nút Phân tổ (Chỉ hiện khi isEditable = true)
          if (isEditable)
            ElevatedButton(
              onPressed: onAssign, // Gọi callback được truyền vào
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Xanh dương đậm
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 32), // Nút nhỏ gọn
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text("Phân tổ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            )
        ],
      ),
    );
  }
}