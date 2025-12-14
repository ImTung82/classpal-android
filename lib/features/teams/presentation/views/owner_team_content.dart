import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/team_models.dart'; // Import Model
import '../view_models/team_view_model.dart';
import '../widgets/group_card.dart';
import '../widgets/unassigned_member_item.dart';
import '../widgets/create_team_dialog.dart';
import '../widgets/all_member_item.dart'; // [IMPORT MỚI]

class OwnerTeamContent extends ConsumerStatefulWidget {
  const OwnerTeamContent({super.key});

  @override
  ConsumerState<OwnerTeamContent> createState() => _OwnerTeamContentState();
}

class _OwnerTeamContentState extends ConsumerState<OwnerTeamContent> {
  int _selectedTabIndex = 0;
  final TextEditingController _searchController = TextEditingController(); // Controller tìm kiếm
  String _searchKeyword = ""; // Biến lưu từ khóa

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showCreateTeamDialog() {
    // ... (Giữ nguyên code dialog cũ của bạn)
     showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return CreateTeamDialog(
          onSubmit: (name, color) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Đã tạo $name thành công!"), backgroundColor: Color(color), behavior: SnackBarBehavior.floating),
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

          // ================= NỘI DUNG TAB 0: THEO TỔ =================
          if (_selectedTabIndex == 0) ...[
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: _showCreateTeamDialog,
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
                children: members.map((member) => UnassignedMemberItem(member: member, isEditable: true)).toList(),
              ),
            ),

          // ================= NỘI DUNG TAB 1: TẤT CẢ THÀNH VIÊN =================
          ] else ...[
            // 1. Thanh tìm kiếm
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Tìm kiếm thành viên...",
                  hintStyle: GoogleFonts.roboto(color: Colors.grey),
                  prefixIcon: const Icon(LucideIcons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Nút Thêm thành viên (Optional - giống thiết kế image_5e7002.png)
            SizedBox(
              width: double.infinity, height: 48,
              child: ElevatedButton.icon(
                onPressed: () {}, // Logic mời thành viên
                icon: const Icon(LucideIcons.userPlus, size: 18),
                label: const Text("Thêm thành viên"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A84F8), // Màu xanh dương
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Danh sách Header + List
            groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Text('Lỗi: $err'),
              data: (groups) {
                return unassignedAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                  data: (unassigned) {
                    // --- LOGIC GỘP DANH SÁCH & TÌM KIẾM ---
                    
                    // 1. Tạo list phẳng chứa thông tin (Member + TeamName + Color)
                    List<Map<String, dynamic>> allMembersFlat = [];

                    // Thêm từ các Tổ
                    for (var group in groups) {
                      for (var member in group.members) {
                        allMembersFlat.add({
                          'member': member,
                          'teamName': group.name,
                          'teamColor': group.color,
                        });
                      }
                    }

                    // Thêm từ Chưa phân tổ
                    for (var member in unassigned) {
                      allMembersFlat.add({
                        'member': member,
                        'teamName': 'Chưa phân tổ',
                        'teamColor': 0xFF9CA3AF, // Màu xám
                      });
                    }

                    // 2. Lọc theo từ khóa
                    final filteredList = allMembersFlat.where((item) {
                      final m = item['member'] as TeamMember;
                      return m.name.toLowerCase().contains(_searchKeyword) || 
                             m.email.toLowerCase().contains(_searchKeyword);
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header số lượng
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tất cả thành viên", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text("${filteredList.length} người", style: GoogleFonts.roboto(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Render List
                        if (filteredList.isEmpty)
                           const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Không tìm thấy thành viên"))),
                        
                        ...filteredList.map((item) {
                          final member = item['member'] as TeamMember;
                          return AllMemberItem(
                            member: member,
                            teamName: item['teamName'],
                            teamColor: item['teamColor'],
                            onEdit: () {
                              // Handle Edit
                            },
                            onDelete: () {
                              // Handle Delete
                            },
                          );
                        }),
                      ],
                    );
                  },
                );
              },
            ),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTabButton(int index, String text) {
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