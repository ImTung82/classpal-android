import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../dashboard/presentation/views/owner_dashboard_content.dart'; 

class OwnerShellScreen extends ConsumerStatefulWidget {
  const OwnerShellScreen({super.key});
  @override
  ConsumerState<OwnerShellScreen> createState() => _OwnerShellScreenState();
}

class _OwnerShellScreenState extends ConsumerState<OwnerShellScreen> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const OwnerDashboardContent(),
    const Center(child: Text("Màn hình Đội nhóm (Tạm)")), // Placeholder do chưa làm teams
    const Center(child: Text("Màn hình Trực nhật")),
    const Center(child: Text("Màn hình Tài sản")),
    const Center(child: Text("Màn hình Sự kiện")),
    const Center(child: Text("Màn hình Quỹ lớp")),
  ];

  String _getSubtitleForIndex(int index) {
    switch (index) {
      case 0: return "Trang chủ";
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
      backgroundColor: Colors.white,
      appBar: AppHeader(title: "Lớp CNTT K20", subtitle: _getSubtitleForIndex(_currentIndex), onMenuPressed: () {}),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: AppBottomNav(currentIndex: _currentIndex, onTap: (index) => setState(() => _currentIndex = index)),
    );
  }
}