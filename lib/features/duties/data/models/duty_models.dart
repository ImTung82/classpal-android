class GroupScore {
  final int rank;
  final String groupName;
  final int memberCount;
  final int score;

  GroupScore({
    required this.rank,
    required this.groupName,
    required this.memberCount,
    required this.score,
  });

  factory GroupScore.fromMap(Map<String, dynamic> map, int rank) {
    return GroupScore(
      rank: rank,
      groupName: map['name'] ?? '',
      memberCount: map['member_count'] ?? 0,
      score: map['score'] ?? 0,
    );
  }
}

class DutyTask {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String dateRange;
  final String status;
  final String? teamId;
  final DateTime? date;

  DutyTask({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dateRange,
    this.status = 'Upcoming',
    this.teamId,
    this.date,
  });

  factory DutyTask.fromMap(Map<String, dynamic> map) {
    final team = map['teams'];
    final date = map['date'] != null ? DateTime.parse(map['date']) : null;
    final rawStatus = map['status'] ?? 'pending';

    // --- Xử lý tách Title và Description từ trường 'note' ---
    String rawNote = map['note'] ?? '';
    String title = 'Trực nhật';
    String description = '';

    if (rawNote.contains(':')) {
      List<String> parts = rawNote.split(':');
      title = parts[0].trim();
      description = parts.sublist(1).join(':').trim();
    } else {
      title = rawNote.isNotEmpty ? rawNote : 'Trực nhật';
      description = '';
    }

    // --- Logic phân loại Status để hiển thị màu sắc CSS ---
    String displayStatus = 'Upcoming';

    if (rawStatus == 'completed') {
      displayStatus = 'Done'; // Màu xanh - Hoàn thành, bảo toàn điểm
    } else if (rawStatus == 'failed') {
      displayStatus = 'Missed'; // Màu đỏ - Thất bại, bị trừ 5 điểm
    } else if (date != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dutyDate = DateTime(date.year, date.month, date.day);

      if (dutyDate.isBefore(today)) {
        displayStatus = 'Active';
      } else if (dutyDate.isAtSameMomentAs(today)) {
        displayStatus = 'Active'; // Nhiệm vụ hôm nay
      } else {
        displayStatus = 'Upcoming'; // Nhiệm vụ tương lai
      }
    }

    return DutyTask(
      id: map['id'] ?? '',
      title: title,
      description: description.isNotEmpty
          ? description
          : 'Hoàn thành để tích lũy điểm cho đội nhóm của bạn!',
      assignedTo: team?['name'] ?? 'Chưa phân công',
      dateRange: _formatDateRange(date),
      status: displayStatus,
      teamId: map['team_id'],
      date: date,
    );
  }

  static String _formatDateRange(DateTime? date) {
    if (date == null) return 'Chưa xác định';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dutyDate = DateTime(date.year, date.month, date.day);

    if (dutyDate.isAtSameMomentAs(today)) {
      return 'Hôm nay (${date.day}/${date.month})';
    } else if (dutyDate.difference(today).inDays == 1) {
      return 'Ngày mai (${date.day}/${date.month})';
    } else if (dutyDate.isAfter(today)) {
      return '${date.day}/${date.month}/${date.year}';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}
