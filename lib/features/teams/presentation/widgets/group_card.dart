import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/team_models.dart';
import 'team_member_item.dart';

class GroupCard extends StatelessWidget {
  final TeamGroup group;
  final bool isEditable; 

  const GroupCard({
    super.key, 
    required this.group, 
    this.isEditable = false
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(group.color);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: themeColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.users, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(group.name, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                      child: Text("${group.members.length} thành viên", style: GoogleFonts.roboto(color: Colors.white, fontSize: 12)),
                    ),
                    if (isEditable) ...[
                      const SizedBox(width: 12),
                      const Icon(LucideIcons.trash2, color: Colors.white, size: 18),
                    ]
                  ],
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (isEditable)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(LucideIcons.userPlus, size: 16),
                      label: const Text("Thêm thành viên"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor.withOpacity(0.1),
                        foregroundColor: themeColor,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                if (group.members.isEmpty)
                   Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text("Chưa có thành viên nào", style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey)),
                   )
                else
                  ...group.members.map((m) => TeamMemberItem(
                    member: m, 
                    isEditable: isEditable,
                    onRemove: () {}, 
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}