import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_models.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return MockDashboardRepository();
});

abstract class DashboardRepository {
  // Cho Lớp trưởng
  Future<List<StatData>> fetchStats();
  Future<List<DutyData>> fetchDuties();
  Future<List<EventData>> fetchEvents();
  
  // Cho Sinh viên
  Future<StudentTaskData> fetchStudentTask();
  Future<List<GroupMemberData>> fetchGroupMembers();
}

class MockDashboardRepository implements DashboardRepository {
  @override
  Future<List<StatData>> fetchStats() async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    return [
      StatData("Tổng sinh viên", "50", "+2", 1, 0xFF4A84F8),
      StatData("Sự kiện sắp tới", "3", "", 2, 0xFFA855F7),
      StatData("Quỹ lớp", "4.5M", "+500K", 3, 0xFF22C55E),
      StatData("Tài sản", "12", "", 4, 0xFFF97316),
    ];
  }

  @override
  Future<List<DutyData>> fetchDuties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DutyData("Tổ 3", "Trực nhật - Tuần này", "In Progress", ""),
      DutyData("Tổ 4", "Trực nhật - Tuần sau", "Upcoming", ""),
      DutyData("Tổ 1", "Giặt giẻ lau - Tuần này", "Done", ""),
    ];
  }

  @override
  Future<List<EventData>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      EventData("Hội thảo Khởi nghiệp 2024", "15/12/2024", 42, 50),
      EventData("Tham quan Doanh nghiệp", "20/12/2024", 35, 50),
    ];
  }

  @override
  Future<StudentTaskData> fetchStudentTask() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return StudentTaskData("Trực nhật - Tổ 3", "06/12 - 13/12/2024");
  }

  @override
  Future<List<GroupMemberData>> fetchGroupMembers() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return [
      GroupMemberData("Đặng Văn G", "0xFF7C3AED"), // Tím
      GroupMemberData("Mai Thị H", "0xFF2563EB"), // Xanh dương
      GroupMemberData("Lê Văn I", "0xFFDB2777"), // Hồng
      GroupMemberData("Phạm Văn K", "0xFF059669"), // Xanh lá
    ];
  }
}