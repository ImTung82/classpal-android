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
      memberCount:
          (map['class_members'] != null &&
              (map['class_members'] as List).isNotEmpty)
          ? map['class_members'][0]['count'] as int
          : 0,
      score: map['score'] ?? 0,
    );
  }
}

class DutyTask {
  final String id;
  final String generalId;
  final String title;
  final String description;
  final String assignedTo;
  final String dateRange;
  final String status;
  final String? teamId;
  final DateTime? startTime;
  final DateTime? endTime;

  DutyTask({
    required this.id,
    required this.generalId,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dateRange,
    this.status = 'Upcoming',
    this.teamId,
    this.startTime,
    this.endTime,
  });

  factory DutyTask.fromMap(Map<String, dynamic> map) {
    final team = map['teams'];
    final start = map['start_time'] != null
        ? DateTime.parse(map['start_time']).toLocal()
        : null;
    final end = map['end_time'] != null
        ? DateTime.parse(map['end_time']).toLocal()
        : null;
    final rawStatus = map['status'] ?? 'pending';

    // Xử lý note để tách title và description
    String rawNote = map['note'] ?? '';
    String title = 'Trực nhật';
    String description = '';
    if (rawNote.contains(':')) {
      List<String> parts = rawNote.split(':');
      title = parts[0].trim();
      description = parts.sublist(1).join(':').trim();
    } else {
      title = rawNote.isNotEmpty ? rawNote : 'Trực nhật';
    }

    // Logic tính toán trạng thái hiển thị
    String displayStatus = 'Upcoming';
    final now = DateTime.now();

    if (rawStatus == 'completed') {
      displayStatus = 'Done';
    } else if (start != null && end != null) {
      if (now.isAfter(start) &&
          now.isBefore(end.add(const Duration(days: 1)))) {
        displayStatus = 'Active';
      } else if (now.isAfter(end)) {
        displayStatus = 'Missed';
      }
    }

    return DutyTask(
      id: map['id'] ?? '',
      generalId: map['general_id'] ?? '',
      title: title,
      description: description.isNotEmpty
          ? description
          : 'Hoàn thành để tích lũy +5 điểm!',
      assignedTo: team?['name'] ?? 'Chưa phân công',
      dateRange: _formatDateRange(start, end),
      status: displayStatus,
      teamId: map['team_id'],
      startTime: start,
      endTime: end,
    );
  }

  static String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Chưa xác định';
    return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }
}
