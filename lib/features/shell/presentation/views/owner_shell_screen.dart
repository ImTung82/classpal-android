import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';
// [IMPORT MỚI] Import Widget Menu
import '../../../../core/widgets/app_menu_drawer.dart';

import '../../../dashboard/presentation/views/owner_dashboard_content.dart'; 
import '../../../teams/presentation/views/owner_team_content.dart'; 
import '../../../duties/presentation/views/owner_duty_content.dart';
import '../../../funds/presentation/views/owner_fund_content.dart';

class OwnerShellScreen extends ConsumerStatefulWidget {
  const OwnerShellScreen({super.key});

  @override
  ConsumerState<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends ConsumerState<OwnerShellScreen> {
  int _currentIndex = 0;
  
  // [THÊM] Key để điều khiển Scaffold (Mở Drawer)
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Widget> _pages = [
    const OwnerDashboardContent(),   
    const OwnerTeamContent(),   
    const OwnerDutyContent(),
    const Center(child: Text("Màn hình Tài sản")),   
    const Center(child: Text("Màn hình Sự kiện")),   
    const OwnerFundContent(),
  ];

  String _getSubtitleForIndex(int index) {
     // ... (Giữ nguyên logic cũ) ...
     // Viết lại ngắn gọn cho bạn copy nếu cần:
    switch (index) {
      case 0: return "Lớp trưởng";
      case 1: return "Quản lý Đội nhóm";
      case 2: return "Phân công Trực nhật";
      case 3: return "Quản lý Tài sản";
      case 4: return "Sự kiện lớp";
      case 5: return "Thu chi Quỹ lớp";
      default: return "Lớp trưởng";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // [THÊM] Gắn Key vào Scaffold
      backgroundColor: Colors.white,
      
      // [THÊM] Khai báo endDrawer (Drawer mở từ bên phải)
      endDrawer: const AppMenuDrawer(isOwner: true), 

      appBar: AppHeader(
        title: "Lớp CNTT K20",
        subtitle: _getSubtitleForIndex(_currentIndex), 
        onMenuPressed: () {
          // [SỬA] Gọi hàm mở Drawer thông qua Key
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