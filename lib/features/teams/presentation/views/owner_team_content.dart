import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/team_view_model.dart';
import '../widgets/group_card.dart';
import '../widgets/unassigned_member_item.dart';
import '../widgets/create_team_dialog.dart'; // [IMPORT] Widget vừa tạo

class OwnerTeamContent extends ConsumerStatefulWidget {
  const OwnerTeamContent({super.key});

  @override
  ConsumerState<OwnerTeamContent> createState() => _OwnerTeamContentState();
}

class _OwnerTeamContentState extends ConsumerState<OwnerTeamContent> {
  int _selectedTabIndex = 0; 

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CreateTeamDialog(
          onSubmit: (name, color) {
            // Hiển thị thông báo giả lập
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Đã tạo $name thành công!"),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(teamGroupsProvider);
    final unassignedAsync = ref.watch(unassignedMembersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quản lý tổ", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Tổ chức và phân công thành viên", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          // Tab Switcher
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(25)),
            child: Row(
              children: [
                _buildTabButton(0, "Theo tổ"),
                _buildTabButton(1, "Tất cả thành viên"),
              ],
            ),
          ),
          const SizedBox(height: 16),

          if (_selectedTabIndex == 0) ...[
            // Nút Tạo tổ mới
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: _showCreateTeamDialog, // [GỌI HÀM Ở ĐÂY]
                icon: const Icon(LucideIcons.plus), 
                label: const Text("Tạo tổ mới"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA), 
                  foregroundColor: Colors.white, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ... (Giữ nguyên phần danh sách Group và Unassigned như code cũ)
            groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Lỗi: $err'),
              data: (groups) => Column(
                children: groups.map((g) => GroupCard(group: g, isEditable: true)).toList(),
              ),
            ),

            const Divider(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Chưa phân tổ", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                unassignedAsync.when(
                  data: (list) => Text("${list.length} người", style: GoogleFonts.roboto(color: Colors.grey)),
                  loading: () => const SizedBox(), error: (_,__) => const SizedBox(),
                )
              ],
            ),
            const SizedBox(height: 12),
            
            unassignedAsync.when(
              loading: () => const SizedBox(),
              error: (err, stack) => Text('Lỗi: $err'),
              data: (members) => Column(
                children: members.map((member) => UnassignedMemberItem(
                  member: member,
                  isEditable: true
                )).toList(),
              ),
            ),

          ] else ...[
             const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("Danh sách tất cả thành viên"))),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
    // ... (Giữ nguyên code cũ)
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(text, style: GoogleFonts.roboto(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.black : Colors.grey, fontSize: 13)),
          ),
        ),
      ),
    );
  }
}