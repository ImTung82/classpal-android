import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../classes/data/models/class_model.dart'; // [IMPORT MODEL]

import '../../../dashboard/presentation/views/student_dashboard_content.dart';
import '../../../teams/presentation/views/student_team_content.dart';
import '../../../duties/presentation/views/student_duty_content.dart';
import '../../../funds/presentation/views/student_fund_content.dart';
import '../../../assets/presentation/views/student_asset_content.dart';
import '../../../events/presentation/views/student_event_content.dart';

class StudentShellScreen extends ConsumerStatefulWidget {
  final ClassModel classModel; // [MỚI]

  const StudentShellScreen({super.key, required this.classModel});

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  int _currentIndex = 0;
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
    switch (index) {
      case 0:
        return "Thành viên";
      case 1:
        return "Đội nhóm";
      // ... thêm các case khác nếu cần
      default:
        return "Thành viên";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // [TRUYỀN CLASS MODEL VÀO DRAWER]
      endDrawer: AppMenuDrawer(classModel: widget.classModel),

      appBar: AppHeader(
        classModel: widget.classModel, // [TRUYỀN DATA THẬT]
        subtitle: _getSubtitleForIndex(_currentIndex),
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        onNotificationPressed: () {
          // Chuyển đến
        }
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
