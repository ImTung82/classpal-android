import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/team_view_model.dart'; //
import '../widgets/group_card.dart'; //
import '../widgets/unassigned_member_item.dart'; //

class StudentTeamContent extends ConsumerWidget {
  final String classId; // Đảm bảo có tham số này để khớp với logic Repository

  const StudentTeamContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Truyền classId vào provider
    final groupsAsync = ref.watch(teamGroupsProvider(classId));
    final unassignedAsync = ref.watch(unassignedMembersProvider(classId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Text("Danh sách tổ", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Xem thành viên trong từng tổ", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          // 2. Danh sách các tổ
          groupsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Lỗi: $err'),
            data: (groups) => Column(
              children: groups.map((g) => GroupCard(
                group: g, 
                isEditable: false // Học sinh chỉ xem, không sửa
              )).toList(),
            ),
          ),

          // 3. Đường kẻ phân cách (Giống bên Owner)
          const Divider(height: 40),

          // 4. Header "Chưa phân tổ" (Đã sửa lại cho giống Owner)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Chưa phân tổ", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
              
              // Hiển thị số lượng người
              unassignedAsync.when(
                data: (list) => Text("${list.length} người", style: GoogleFonts.roboto(color: Colors.grey)),
                loading: () => const SizedBox(), 
                error: (_,__) => const SizedBox(),
              )
            ],
          ),
          const SizedBox(height: 12),

          // 5. Danh sách thành viên chưa phân tổ (Bỏ khung Container trắng)
          unassignedAsync.when(
            loading: () => const SizedBox(),
            error: (err, stack) => const SizedBox(),
            data: (members) => Column(
              children: members.map((member) => UnassignedMemberItem(
                member: member,
                isEditable: false // Học sinh không thấy nút "Phân tổ"
              )).toList(),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}