// Model thống kê (Owner)
class StatData {
  final String title;
  final String value;
  final String subValue;
  final int iconCode;
  final int color;

  StatData(this.title, this.value, this.subValue, this.iconCode, this.color);
}

// Model nhiệm vụ chung (Owner xem list)
class DutyData {
  final String groupName;
  final String taskName;
  final String status; // 'In Progress', 'Upcoming', 'Done'
  final String time;

  DutyData(this.groupName, this.taskName, this.status, this.time);
}

// Model sự kiện
class EventData {
  final String title;
  final String date;
  final int current;
  final int total;

  EventData(this.title, this.date, this.current, this.total);
}

// Model nhiệm vụ cá nhân (Student)
class StudentTaskData {
  final String title;       
  final String dateRange;   
  final bool isCompleted;

  StudentTaskData(this.title, this.dateRange, {this.isCompleted = false});
}

// Model thành viên tổ (Dùng hiển thị avatar nhỏ)
class GroupMemberData {
  final String name;
  final String avatarColor; 

  GroupMemberData(this.name, this.avatarColor);
}