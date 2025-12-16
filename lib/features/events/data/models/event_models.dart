enum EventStatus {
  upcoming,     // Sắp diễn ra (Chưa đăng ký)
  registered,   // Đã đăng ký (Hiện nút Hủy)
  participated, // Đã tham gia (Hiện thẻ xanh)
}

class ClassEvent {
  final String id;
  final String title;
  final String description;
  final String date;        // VD: 15/12/2024
  final String time;        // VD: 14:00 - 16:00
  final String location;    // VD: Hội trường A
  final bool isMandatory;   // Bắt buộc (Thẻ đỏ)
  final EventStatus status; 

  ClassEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.isMandatory = false,
    required this.status,
  });
}