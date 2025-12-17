// File: lib/features/events/data/models/event_models.dart

enum EventStatus { upcoming, registered, participated }

class Student {
  final String id;
  final String name;
  final String? avatarUrl;

  Student({required this.id, required this.name, this.avatarUrl});
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
  final bool isOpen; // Trạng thái mở đăng ký

  // Dùng List chứa dữ liệu thực ---
  final List<Student> participants; // Danh sách Tham gia
  final List<Student> nonParticipants; // Danh sách Không tham gia
  final List<Student> unconfirmed; // Danh sách Chưa xác nhận

  ClassEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    this.isMandatory = false,
    this.status = EventStatus.upcoming,
    this.isOpen = true,
    // Mặc định là danh sách rỗng
    this.participants = const [],
    this.nonParticipants = const [],
    this.unconfirmed = const [],
  });

  // --- Getters: Tự động tính toán số liệu từ danh sách ---

  // 1. Số lượng đã đăng ký = Độ dài danh sách tham gia
  int get registeredCount => participants.length;

  // 2. Số lượng chưa đăng ký (chưa xác nhận) = Độ dài danh sách chưa xác nhận
  int get unregisteredCount => unconfirmed.length;

  // 3. Tổng số sinh viên = Tổng 3 danh sách cộng lại
  int get totalCount =>
      participants.length + nonParticipants.length + unconfirmed.length;

  // 4. % Hoàn thành (Progress bar)
  double get progress => totalCount == 0 ? 0 : registeredCount / totalCount;
}
