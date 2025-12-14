import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../dashboard/presentation/views/student_dashboard_content.dart';
import '../../../teams/presentation/views/student_team_content.dart';

class StudentShellScreen extends ConsumerStatefulWidget {
  const StudentShellScreen({super.key});
  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const StudentDashboardContent(),
    const StudentTeamContent(),
    const Center(child: Text("Lịch trực nhật")),
    const Center(child: Text("Tài sản lớp")),
    const Center(child: Text("Sự kiện")),
    const Center(child: Text("Đóng quỹ")),
  ];

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0: return "Thành viên";
      case 1: return "Đội nhóm";
      default: return "Thành viên";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppHeader(title: "Lớp Toán K20", subtitle: _getSubtitleForIndex(_currentIndex), onMenuPressed: () {}),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index)),
    );
  }
}