import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/dashboard_models.dart';

class GroupMemberItem extends StatelessWidget {
  final GroupMemberData member;
  const GroupMemberItem({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final color = Color(int.parse(member.avatarColor));
    final isLeader = member.isLeader; // Biến kiểm tra tổ trưởng từ model

    // Style tương đồng với TeamMemberItem
    final borderColor = isLeader
        ? Colors.orange.withOpacity(0.6)
        : Colors.grey.shade200;
    final borderWidth = isLeader ? 1.5 : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white, // Chuyển sang nền trắng để nổi bật viền
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
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
          // 1. Avatar + Ngôi sao nếu là Leader
          Stack(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    member.name.substring(0, 1),
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
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

          // 2. Tên và nhãn Badge
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    member.name,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: isLeader ? FontWeight.bold : FontWeight.w500,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isLeader) ...[
                  const SizedBox(width: 8),
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
          ),
        ],
      ),
    );
  }
}
