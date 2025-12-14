import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';

// Import màn hình nội dung Dashboard
import '../../../dashboard/presentation/views/owner_dashboard_content.dart'; 

// [QUAN TRỌNG] Import màn hình Teams của Lớp Trưởng
import '../../../teams/presentation/views/owner_team_content.dart'; 

class OwnerShellScreen extends ConsumerStatefulWidget {
  const OwnerShellScreen({super.key});

  @override
  ConsumerState<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends ConsumerState<OwnerShellScreen> {
  int _currentIndex = 0;

  // Danh sách màn hình
  final List<Widget> _pages = [
    const OwnerDashboardContent(),   // Tab 0: Dashboard
    const TeamManagementContent(),   // Tab 1: Đội nhóm (Đã thay thế Placeholder bằng màn hình thật)
    const Center(child: Text("Màn hình Trực nhật")), // Tab 2
    const Center(child: Text("Màn hình Tài sản")),   // Tab 3
    const Center(child: Text("Màn hình Sự kiện")),   // Tab 4
    const Center(child: Text("Màn hình Quỹ lớp")),   // Tab 5
  ];

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0: return "Lớp trưởng";
      case 1: return "Quản lý Đội nhóm"; // Subtitle cho tab Teams
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
      backgroundColor: Colors.white,
      
      // Header
      appBar: AppHeader(
        title: "Lớp CNTT K20",
        subtitle: _getSubtitleForIndex(_currentIndex), 
        onMenuPressed: () {},
      ),
      
      // Body (Giữ trạng thái cuộn)
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      
      // Footer
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}