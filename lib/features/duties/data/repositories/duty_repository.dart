import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/duty_models.dart';

final dutyRepositoryProvider = Provider<DutyRepository>((ref) => MockDutyRepository());

abstract class DutyRepository {
  Future<List<GroupScore>> fetchScoreBoard();
  Future<List<DutyTask>> fetchActiveDuties(); // Cho Owner
  Future<DutyTask?> fetchMyDuty(); // Cho Student (Nhiệm vụ chính)
  Future<List<DutyTask>> fetchUpcomingDuties(); // Cho Student (Lịch sắp tới)
}

class MockDutyRepository implements DutyRepository {
  @override
  Future<List<GroupScore>> fetchScoreBoard() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      GroupScore(rank: 1, groupName: "Tổ 2", memberCount: 3, score: 92),
      GroupScore(rank: 2, groupName: "Tổ 4", memberCount: 3, score: 88),
      GroupScore(rank: 3, groupName: "Tổ 1", memberCount: 3, score: 85),
      GroupScore(rank: 4, groupName: "Tổ 3", memberCount: 3, score: 78),
    ];
  }

  @override
  Future<List<DutyTask>> fetchActiveDuties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DutyTask(
        id: '1', title: "Trực nhật tuần", 
        description: "Vệ sinh lớp học, lau bảng, sắp xếp bàn ghế", 
        assignedTo: "Tổ 3", dateRange: "Tuần 3 • Bắt đầu: 06/12/2024", status: 'Active'
      ),
       DutyTask(
        id: '2', title: "Giặt giẻ lau", 
        description: "Đảm bảo giẻ lau sạch sẽ đầu giờ", 
        assignedTo: "Tổ 1", dateRange: "Tuần 3", status: 'Active'
      ),
    ];
  }

  @override
  Future<DutyTask?> fetchMyDuty() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DutyTask(
      id: '1', title: "Tổ 3 - Trực nhật tuần", 
      description: "Vệ sinh lớp học, lau bảng, sắp xếp bàn ghế", 
      assignedTo: "Tổ 3", dateRange: "Tuần này (06/12 - 13/12)", status: 'Active'
    );
  }

  @override
  Future<List<DutyTask>> fetchUpcomingDuties() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      DutyTask(id: '3', title: "Trực nhật tuần", description: "", assignedTo: "Tổ 4", dateRange: "Tuần sau", status: 'Upcoming'),
      DutyTask(id: '4', title: "Giặt giẻ lau", description: "", assignedTo: "Tổ 3", dateRange: "Tuần sau", status: 'Upcoming'),
    ];
  }
}