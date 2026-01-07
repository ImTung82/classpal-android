// Model thống kê (Owner)
class StatData {
  final String title;
  final String value;
  final String subValue;
  final int iconCode;
  final int color;

  StatData(this.title, this.value, this.subValue, this.iconCode, this.color);
}

// Model nhiệm vụ chung (Owner xem list tổng quát)
class DutyData {
  final String groupName;
  final String taskName;
  final String status; 
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

// Model nhiệm vụ cá nhân (Student & Leader Dashboard)
class StudentTaskData {
  final String id; 
  final String title;
  final String dateRange;
  final bool isCompleted;
  final String status; 

  StudentTaskData({
    required this.id,
    required this.title,
    required this.dateRange,
    this.isCompleted = false,
    this.status = 'Active',
  });
}

//  Model thành viên tổ 
class GroupMemberData {
  final String name;
  final String avatarColor;
  final bool isLeader; 

  GroupMemberData({
    required this.name,
    required this.avatarColor,
    this.isLeader = false, 
  });
}
