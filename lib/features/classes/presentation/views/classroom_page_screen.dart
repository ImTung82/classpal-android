import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart'; // [IMPORT ICON]

// [IMPORT CORE WIDGETS]
import '../../../../core/widgets/app_menu_drawer.dart';

// [IMPORT MODELS & VIEW MODELS]
import '../../data/models/class_model.dart';
import '../view_models/class_view_model.dart';

// [IMPORT SCREENS]
import 'create_class_screen.dart';
import 'join_class_screen.dart';
import '../../../shell/presentation/views/owner_shell_screen.dart';
import '../../../shell/presentation/views/student_shell_screen.dart';

class ClassroomPageScreen extends ConsumerWidget {
  const ClassroomPageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe dữ liệu
    final asyncClasses = ref.watch(classListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      
      // [THAY ĐỔI 1] Dùng endDrawer để menu trượt từ PHẢI sang (vì nút bấm nằm bên phải)
      endDrawer: const AppMenuDrawer(classModel: null), 

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút mặc định bên trái
        
        // Title: Giữ nguyên giao diện đẹp của bạn
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6A5AE0), Color(0xFF8F7CFF)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Lớp học của bạn',
              style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
            ),
          ],
        ),
        
        // [THAY ĐỔI 2] Nút Menu nằm ở bên phải (Actions)
        actions: [
          Builder(
            builder: (context) => IconButton(
              // Dùng icon Menu thay vì Refresh
              icon: const Icon(LucideIcons.menu, color: Colors.black87), 
              onPressed: () => Scaffold.of(context).openEndDrawer(), // Mở endDrawer
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      
      body: asyncClasses.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF6A5AE0))),
        error: (err, stack) => Center(child: Text("Lỗi: $err")),
        data: (classes) {
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(classListProvider.future),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 1 + classes.length + 1 + 2 + 1,
              itemBuilder: (context, index) {
                
                // A. Header Text
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      classes.isEmpty 
                        ? 'Bạn chưa tham gia lớp nào' 
                        : 'Danh sách lớp bạn đang tham gia',
                      style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
                      textAlign: classes.isEmpty ? TextAlign.center : TextAlign.start,
                    ),
                  );
                }

                // B. Danh sách lớp học
                final classIndex = index - 1;
                if (classIndex < classes.length) {
                  return _classCard(context: context, item: classes[classIndex]);
                }

                // C. Separator "HOẶC"
                if (classIndex == classes.length) {
                  if (classes.isEmpty) return _buildEmptyState();
                  return _buildSeparator();
                }

                // D. Nút Tạo lớp
                if (classIndex == classes.length + 1) {
                  return Column(
                    children: [
                      _actionButton(
                        context,
                        title: 'Tạo lớp học mới',
                        subtitle: 'Bạn sẽ trở thành lớp trưởng',
                        icon: Icons.add,
                        gradient: const [Color(0xFF6A5AE0), Color(0xFF8F7CFF)],
                        textColor: Colors.white,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateClassScreen())),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                }

                // E. Nút Tham gia lớp
                if (classIndex == classes.length + 2) {
                  return _actionButton(
                    context,
                    title: 'Tham gia lớp học',
                    subtitle: 'Nhập mã lớp để tham gia',
                    icon: Icons.login,
                    color: Colors.white,
                    textColor: Colors.black,
                    isBorder: true,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const JoinClassScreen())),
                  );
                }

                return const SizedBox(height: 40);
              },
            ),
          );
        },
      ),
    );
  }

  // --- CÁC WIDGET CON (GIỮ NGUYÊN) ---

  Widget _buildSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "HOẶC",
              style: GoogleFonts.roboto(
                fontSize: 12, 
                color: Colors.grey[400], 
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Icon(Icons.school_outlined, size: 60, color: Colors.grey[200]),
    );
  }

  Widget _classCard({required BuildContext context, required ClassModel item}) {
    final isOwner = item.role == 'owner';
    final cardColor = isOwner ? Colors.deepPurple : Colors.orange;
    final roleText = isOwner ? 'Lớp trưởng' : 'Thành viên';

    return GestureDetector(
      onTap: () {
        if (isOwner) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => OwnerShellScreen(classModel: item)));
        } else {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentShellScreen(classModel: item)));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                  child: Text(item.code, style: GoogleFonts.roboto(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: GoogleFonts.roboto(fontWeight: FontWeight.w600, fontSize: 16)),
                  if (item.schoolName != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(item.schoolName!, style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: isOwner ? Colors.deepPurple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4)
                    ),
                    child: Text(roleText, style: GoogleFonts.roboto(fontSize: 11, color: cardColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(BuildContext context, {
    required String title, required String subtitle, required IconData icon, required VoidCallback onTap,
    List<Color>? gradient, Color? color, Color textColor = Colors.white, bool isBorder = false
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient != null ? LinearGradient(colors: gradient) : null,
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: isBorder ? Border.all(color: Colors.grey.shade200) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isBorder ? const Color.fromARGB(255, 107, 142, 187).withOpacity(0.2) : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: isBorder ? Colors.blue : Colors.white),
                  ),
                  const SizedBox(width: 12, height: 6),
                  Text(title, style: GoogleFonts.roboto(color: textColor, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(subtitle, style: GoogleFonts.roboto(fontSize: 12, color: isBorder ? Colors.black54 : Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward, color: isBorder ? Colors.grey : Colors.white),
          ],
        ),
      ),
    );
  }
}