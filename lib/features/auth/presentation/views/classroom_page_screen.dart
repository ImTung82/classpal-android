import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../dashboard/presentation/views/dashboard_screen.dart'; // Thêm import này

class ClassroomPageScreen extends StatelessWidget {
  const ClassroomPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A5AE0), Color(0xFF8F7CFF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.group, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Lớp học của bạn',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Chọn lớp hoặc tạo mới để bắt đầu',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          _classCard(
            context: context, // Thêm context
            color: Colors.deepPurple,
            title: 'Lớp CNTT K20',
            role: 'Lớp trưởng',
            code: 'KTF742',
          ),
          _classCard(
            context: context,
            color: Colors.orange,
            title: 'Lớp Toán K20',
            role: 'Thành viên',
            code: 'AHUJ88',
          ),
          _classCard(
            context: context,
            color: Colors.pink,
            title: 'Lớp Vật lý K21',
            role: 'Thành viên',
            code: 'HIDQW',
          ),
          const SizedBox(height: 14),
          const Divider(),
          const SizedBox(height: 14),
          Center(
            child: Text('Hoặc', style: GoogleFonts.roboto(color: Colors.grey)),
          ),
          const SizedBox(height: 16),

          _createClassButton(),
          const SizedBox(height: 12),
          _joinClassButton(),
        ],
      ),
    );
  }

  /// Card lớp học
  Widget _classCard({
    required BuildContext context, // Thêm context
    required Color color,
    required String title,
    required String role,
    required String code,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    role,
                    style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _createClassButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF8F7CFF)],
        ),
        borderRadius: BorderRadius.circular(18),
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
                const SizedBox(width: 12, height: 6),
                Text(
                  'Tạo lớp học mới',
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bạn sẽ trở thành lớp trưởng và quản lý lớp học',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.white),
        ],
      ),
    );
  }

  Widget _joinClassButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
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
                    color: const Color.fromARGB(
                      255,
                      107,
                      142,
                      187,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.login, color: Colors.blue),
                ),
                const SizedBox(width: 12, height: 6),
                Text(
                  'Tham gia lớp học',
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nhập mã lớp học và tham gia với tư cách là thành viên',
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.black),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Colors.grey),
        ],
      ),
    );
  }
}
