import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';
// [IMPORT MỚI]
import '../../../../core/widgets/app_menu_drawer.dart';

import '../../../dashboard/presentation/views/student_dashboard_content.dart'; 
import '../../../teams/presentation/views/student_team_content.dart';
import '../../../duties/presentation/views/student_duty_content.dart';
import '../../../funds/presentation/views/student_fund_content.dart';
import '../../../assets/presentation/views/student_asset_content.dart';
import '../../../events/presentation/views/student_event_content.dart';

class StudentShellScreen extends ConsumerStatefulWidget {
  const StudentShellScreen({super.key});

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  int _currentIndex = 0;
  
  // [THÊM] Key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const StudentDashboardContent(),
    const StudentTeamContent(),
    const StudentDutyContent(),
    const StudentAssetContent(),   
    const StudentEventContent(),   
    const StudentFundContent(),   
  ];

  String _getSubtitleForIndex(int index) {
     // ... (Logic cũ giữ nguyên)
     switch (index) {
      case 0: return "Thành viên";
      case 1: return "Đội nhóm";
      default: return "Thành viên";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // [THÊM] Gắn Key
      backgroundColor: Colors.white,

      // [THÊM] Drawer cho sinh viên (isOwner: false)
      endDrawer: const AppMenuDrawer(isOwner: false),

      appBar: AppHeader(
        title: "Lớp Toán K20",
        subtitle: _getSubtitleForIndex(_currentIndex), 
        onMenuPressed: () {
           // [SỬA] Mở Drawer
           _scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}