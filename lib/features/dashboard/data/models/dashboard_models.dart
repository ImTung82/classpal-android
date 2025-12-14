// Chỉ chứa khuôn dữ liệu, không chứa logic
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