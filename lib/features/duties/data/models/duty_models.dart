class GroupScore {
  final int rank;
  final String groupName;
  final int memberCount;
  final int score;

  GroupScore({required this.rank, required this.groupName, required this.memberCount, required this.score});
}

class DutyTask {
  final String id;
  final String title;
  final String description;
  final String assignedTo; // Tên tổ hoặc người được giao
  final String dateRange;
  final String status; // 'Active', 'Upcoming', 'Done'

  DutyTask({
    required this.id, 
    required this.title, 
    required this.description, 
    required this.assignedTo, 
    required this.dateRange,
    this.status = 'Upcoming',
  });
}