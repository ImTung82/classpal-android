class StatData {
  final String title;
  final String value;
  final String subValue;
  final int iconCode;
  final int color;

  StatData(this.title, this.value, this.subValue, this.iconCode, this.color);
}

class DutyData {
  final String groupName;
  final String taskName;
  final String status;
  final String time;

  DutyData(this.groupName, this.taskName, this.status, this.time);
}

class EventData {
  final String title;
  final String date;
  final int current;
  final int total;

  EventData(this.title, this.date, this.current, this.total);
}

// --- MODELS CHO SINH VIÊN ---

class StudentTaskData {
  final String title;       // VD: "Trực nhật - Tổ 3"
  final String dateRange;   // VD: "06/12 - 13/12/2024"
  final bool isCompleted;

  StudentTaskData(this.title, this.dateRange, {this.isCompleted = false});
}

class GroupMemberData {
  final String name;
  final String avatarColor; // Mã màu Hex (VD: "0xFF7C3AED")

  GroupMemberData(this.name, this.avatarColor);
}