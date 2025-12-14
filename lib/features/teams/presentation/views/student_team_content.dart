import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/team_view_model.dart';
import '../widgets/group_card.dart';
import '../widgets/unassigned_member_item.dart';

class StudentTeamContent extends ConsumerWidget {
  const StudentTeamContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(teamGroupsProvider);
    final unassignedAsync = ref.watch(unassignedMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Danh sách tổ", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Xem thành viên trong từng tổ", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi: $err'),
            data: (groups) => Column(
              children: groups.map((g) => GroupCard(
                group: g, 
                isEditable: false 
              )).toList(),
            ),
          ),

          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Chưa phân tổ", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                unassignedAsync.when(
                  loading: () => const SizedBox(),
                  error: (err, stack) => const SizedBox(),
                  data: (members) => Column(
                    children: members.map((member) => UnassignedMemberItem(
                      member: member,
                      isEditable: false 
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}