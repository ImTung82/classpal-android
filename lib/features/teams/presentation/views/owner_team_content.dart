import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/team_model.dart';
import '../view_models/team_view_model.dart';
import '../widgets/group_card.dart';
import '../widgets/unassigned_member_item.dart';
import '../widgets/create_team_dialog.dart';
import '../widgets/select_team_dialog.dart';
import '../widgets/delete_team_dialog.dart';

class OwnerTeamContent extends ConsumerStatefulWidget {
  final String classId;

  const OwnerTeamContent({super.key, required this.classId});

  @override
  ConsumerState<OwnerTeamContent> createState() => _OwnerTeamContentState();
}

class _OwnerTeamContentState extends ConsumerState<OwnerTeamContent> {
  int _selectedTabIndex = 0;
  
  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  // DIALOG 1: TẠO / SỬA TỔ
  void _showTeamDialog({TeamGroup? groupToEdit}) {
    showDialog(
      context: context,
      builder: (context) {
        return CreateTeamDialog(
          initialName: groupToEdit?.name,
          onSubmit: (name) {
             if (groupToEdit == null) {
               // Tạo mới
               ref.read(teamControllerProvider.notifier).createTeam(
                 classId: widget.classId,
                 name: name,
                 onSuccess: () => _showSnackbar("Đã tạo tổ $name", Colors.green),
                 onError: (e) => _showSnackbar(e, Colors.red),
               );
             } else {
               // Sửa
               ref.read(teamControllerProvider.notifier).updateTeam(
                 classId: widget.classId,
                 teamId: groupToEdit.id,
                 name: name,
                 onSuccess: () => _showSnackbar("Đã cập nhật tên tổ", Colors.green),
                 onError: (e) => _showSnackbar(e, Colors.red),
               );
             }
          },
        );
      },
    );
  }

  // DIALOG 2: XÁC NHẬN XÓA TỔ
  void _confirmDeleteTeam(TeamGroup group) {
    showDialog(
      context: context,
      builder: (ctx) => DeleteTeamDialog(
        teamName: group.name,
        onDelete: () {
          ref.read(teamControllerProvider.notifier).deleteTeam(
            classId: widget.classId,
            teamId: group.id,
            onSuccess: () => _showSnackbar("Đã xóa tổ", Colors.grey),
            onError: (e) => _showSnackbar(e, Colors.red),
          );
        },
      ),
    );
  }

  // DIALOG 3: CHỌN TỔ CHO THÀNH VIÊN
  void _showSelectTeamDialog(String memberId) {
    showDialog(
      context: context,
      builder: (context) => SelectTeamDialog(
        classId: widget.classId,
        onSelected: (teamId) {
          ref.read(teamControllerProvider.notifier).assignMember(
            classId: widget.classId,
            memberId: memberId,
            teamId: teamId,
            onSuccess: () => _showSnackbar("Đã phân tổ thành công", Colors.green),
            onError: (e) => _showSnackbar(e, Colors.red),
          );
        },
      ),
    );
  }

  // [MỚI] Hàm xử lý Refresh
  Future<void> _onRefresh() async {
    // Gọi ref.refresh(...).future để ép tải lại và đợi cho đến khi xong
    await Future.wait([
      ref.refresh(teamGroupsProvider(widget.classId).future),
      ref.refresh(unassignedMembersProvider(widget.classId).future),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final groupsAsync = ref.watch(teamGroupsProvider(widget.classId));
    final unassignedAsync = ref.watch(unassignedMembersProvider(widget.classId));
    final isLoading = ref.watch(teamControllerProvider).isLoading;

    return Stack(
      children: [
        // [MỚI] Bọc nội dung trong RefreshIndicator
        RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF9333EA), // Màu spinner
          child: SingleChildScrollView(
            // [MỚI] Luôn cho phép cuộn để kích hoạt refresh ngay cả khi nội dung ngắn
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Text("Quản lý tổ", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
                 Text("Tổ chức và phân công thành viên", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
                 const SizedBox(height: 16),
                 
                 // --- NỘI DUNG CHÍNH ---
                 if (_selectedTabIndex == 0) ...[
                   SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _showTeamDialog(), 
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
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (groups) => Column(
                      children: groups.map((g) => GroupCard(
                        group: g, 
                        isEditable: true,
                        onEditGroup: (group) => _showTeamDialog(groupToEdit: group),
                        onDeleteGroup: (group) => _confirmDeleteTeam(group), 
                        onRemoveMember: (member) {
                          ref.read(teamControllerProvider.notifier).removeMember(
                            classId: widget.classId,
                            memberId: member.id,
                            onSuccess: () => _showSnackbar("Đã xóa ${member.name} khỏi tổ", Colors.orange),
                            onError: (e) => _showSnackbar(e, Colors.red),
                          );
                        },
                      )).toList(),
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
                    error: (err, _) => Text('Lỗi: $err'),
                    data: (members) {
                      if (members.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: Text("Tất cả thành viên đã có tổ", style: TextStyle(color: Colors.grey))),
                        );
                      }
                      return Column(
                        children: members.map((member) => UnassignedMemberItem(
                          member: member, 
                          isEditable: true,
                          onAssign: () => _showSelectTeamDialog(member.id),
                        )).toList(),
                      );
                    },
                  ),
                 ],
              ],
            ),
          ),
        ),
        
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}