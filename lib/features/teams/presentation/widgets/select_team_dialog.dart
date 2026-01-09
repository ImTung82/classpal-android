import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/team_model.dart'; //
import '../view_models/team_view_model.dart'; //

class SelectTeamDialog extends ConsumerWidget {
  final String classId;
  final Function(String teamId) onSelected;

  const SelectTeamDialog({
    super.key, 
    required this.classId, 
    required this.onSelected
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(teamGroupsProvider(classId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Text(
                "Chọn tổ", 
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ),
            const SizedBox(height: 24),

            // Danh sách tổ
            groupsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Lỗi: $err")),
              data: (groups) {
                if (groups.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Lớp chưa có tổ nào.\nHãy tạo tổ trước.", 
                        textAlign: TextAlign.center, 
                        style: TextStyle(color: Colors.grey)
                      ),
                    ),
                  );
                }
                
                // Giới hạn chiều cao danh sách để không bị tràn màn hình
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 300), 
                  child: SingleChildScrollView(
                    child: Column(
                      children: groups.map((group) {
                        // Màu avatar tổ
                        final color = Color(group.color);
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: CircleAvatar(
                              backgroundColor: color, 
                              radius: 16, 
                              child: const Icon(Icons.groups, size: 16, color: Colors.white)
                            ),
                            title: Text(group.name, style: GoogleFonts.roboto(fontWeight: FontWeight.w500)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                            onTap: () {
                              onSelected(group.id);
                              Navigator.pop(context); // Đóng dialog sau khi chọn
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Nút Hủy
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(color: Colors.grey.shade300),
                  foregroundColor: Colors.black87,
                ),
                child: const Text("Hủy"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}