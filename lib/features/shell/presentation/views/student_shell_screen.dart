import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../classes/data/models/class_model.dart'; 

import '../../../dashboard/presentation/views/student_dashboard_content.dart';
import '../../../teams/presentation/views/student_team_content.dart';
import '../../../duties/presentation/views/student_duty_content.dart';
import '../../../funds/presentation/views/student_fund_content.dart';
import '../../../assets/presentation/views/student_asset_content.dart';
import '../../../events/presentation/views/student_event_content.dart';
import '../../../notification/presentation/views/student_notification_content.dart';

class StudentShellScreen extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const StudentShellScreen({super.key, required this.classModel});

  @override
  ConsumerState<StudentShellScreen> createState() => _StudentShellScreenState();
}

class _StudentShellScreenState extends ConsumerState<StudentShellScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Khai báo biến trễ
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Khởi tạo page và truyền classId
    _pages = [
      const StudentDashboardContent(),
      StudentTeamContent(classId: widget.classModel.id), // [ĐÃ SỬA] Truyền classId
      const StudentDutyContent(),
      StudentAssetContent(classId: widget.classModel.id),
      const StudentEventContent(),
      StudentFundContent(classId: widget.classModel.id),
      const StudentNotificationContent(),
    ];
  }

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0: return "Thành viên";
      case 1: return "Đội nhóm";
      // ... thêm các case khác nếu cần
      default: return "Thành viên";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      endDrawer: AppMenuDrawer(classModel: widget.classModel),

      appBar: AppHeader(
        classModel: widget.classModel,
        subtitle: _getSubtitleForIndex(_currentIndex),
        onMenuPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
        onNotificationPressed: () {
          setState(() {
            _currentIndex = 6; 
          });
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