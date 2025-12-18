import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_models.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

abstract class EventRepository {
  Future<List<ClassEvent>> fetchEvents();
  Future<List<ClassEvent>> fetchOwnerEvents();
}

class MockEventRepository implements EventRepository {
  @override
  Future<List<ClassEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Dữ liệu cho màn hình cá nhân sinh viên (nếu cần)
    return [
      ClassEvent(
        id: '1',
        title: 'Hội thảo Khởi nghiệp 2024',
        description: 'Hội thảo về xu hướng khởi nghiệp và cơ hội việc làm',
        date: '15/12/2024',
        time: '14:00 - 16:00',
        location: 'Hội trường A',
        isMandatory: true,
        status: EventStatus.registered,
        // Với view cá nhân, ta có thể để trống danh sách chi tiết nếu không dùng
      ),
      ClassEvent(
        id: '2',
        title: 'Tham quan Doanh nghiệp',
        description: 'Chuyến tham quan thực tế tại công ty công nghệ ABC',
        date: '20/12/2024',
        time: '08:00 - 12:00',
        location: 'Tập trung tại cổng trường',
        isMandatory: false,
        status: EventStatus.participated,
      ),
    ];
  }

  @override
  Future<List<ClassEvent>> fetchOwnerEvents() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // 1. Tạo dữ liệu giả Sinh viên
    final svA = Student(id: 'sv001', name: 'Nguyễn Văn A');
    final svB = Student(id: 'sv002', name: 'Trần Thị B');
    final svC = Student(id: 'sv003', name: 'Lê Văn C');
    final svD = Student(id: 'sv004', name: 'Phạm Thị D');
    final svE = Student(id: 'sv005', name: 'Hoàng Văn E');

    return [
      // Sự kiện 1: 3 tham gia, 0 không tham gia, 2 chưa xác nhận
      ClassEvent(
        id: '1',
        title: 'Hội thảo Khởi nghiệp 2024',
        description: 'Hội thảo về xu hướng khởi nghiệp và cơ hội việc làm',
        date: '15/12/2024',
        time: '14:00 - 16:00',
        location: 'Hội trường A',
        isMandatory: true,
        status: EventStatus.upcoming,
        isOpen: true,
        // Gán danh sách sinh viên
        participants: [svA, svB, svC], // 3 người
        nonParticipants: [], // 0 người
        unconfirmed: [svD, svE], // 2 người
      ),

      // Sự kiện 2: 2 tham gia, 2 không tham gia, 1 chưa xác nhận
      ClassEvent(
        id: '2',
        title: 'Tham quan Doanh nghiệp',
        description: 'Chuyến tham quan thực tế tại công ty công nghệ ABC',
        date: '20/12/2024',
        time: '08:00 - 12:00',
        location: 'Tập trung tại cổng trường',
        isMandatory: false,
        status: EventStatus.upcoming,
        isOpen: true,
        // Gán danh sách sinh viên
        participants: [svA, svC], // 2 người
        nonParticipants: [svB, svE], // 2 người
        unconfirmed: [svD], // 1 người
      ),
    ];
  }
}
