import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/app_menu_drawer.dart';
import '../../../classes/data/models/class_model.dart'; 

import '../../../dashboard/presentation/views/owner_dashboard_content.dart';
import '../../../teams/presentation/views/owner_team_content.dart';
import '../../../duties/presentation/views/owner_duty_content.dart';
import '../../../funds/presentation/views/owner_fund_content.dart';
import '../../../assets/presentation/views/owner_asset_content.dart';
import '../../../events/presentation/views/owner_event_content.dart';
import '../../../notification/presentation/views/owner_notification_content.dart';

class OwnerShellScreen extends ConsumerStatefulWidget {
  final ClassModel classModel;

  const OwnerShellScreen({super.key, required this.classModel});

  @override
  ConsumerState<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends ConsumerState<OwnerShellScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Khai báo biến trễ (late) để khởi tạo sau
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách page tại đây để truy cập được widget.classModel
    _pages = [
      const OwnerDashboardContent(),
      OwnerTeamContent(classId: widget.classModel.id), // [ĐÃ SỬA] Truyền classId
      OwnerDutyContent(classId: widget.classModel.id),
      OwnerAssetContent(classId: widget.classModel.id),
      OwnerEventContent(classId: widget.classModel.id),
      const OwnerFundContent(),
      const OwnerNotificationContent(),
    ];
  }

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0: return "Lớp trưởng";
      case 1: return "Quản lý Đội nhóm";
      case 2: return "Phân công Trực nhật";
      case 3: return "Quản lý Tài sản";
      case 4: return "Sự kiện lớp";
      case 5: return "Thu chi Quỹ lớp";
      case 6: return "Thông báo lớp";
      default: return "Lớp trưởng";
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
        },
      ),

      body: IndexedStack(index: _currentIndex, children: _pages),

      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}