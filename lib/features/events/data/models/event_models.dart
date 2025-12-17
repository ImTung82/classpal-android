enum EventStatus {
  upcoming,
  registered,
  participated, // Status của cá nhân
}

class ClassEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final bool isMandatory;
  final EventStatus status; // Status cá nhân (cho SV)

  // --- Thêm trường cho Lớp trưởng ---
  final int registeredCount; // Số lượng đã đăng ký
  final int totalCount; // Tổng số sinh viên
  final bool isOpen; // Trạng thái mở đăng ký

  ClassEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.isMandatory = false,
    this.status = EventStatus.upcoming,
    this.registeredCount = 0,
    this.totalCount = 0,
    this.isOpen = true,
  });

  // Getter tính toán số lượng chưa đăng ký
  int get unregisteredCount => totalCount - registeredCount;
  // Getter tính % hoàn thành
  double get progress => totalCount == 0 ? 0 : registeredCount / totalCount;
}
