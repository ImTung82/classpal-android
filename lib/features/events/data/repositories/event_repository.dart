import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_models.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return MockEventRepository();
});

abstract class EventRepository {
  Future<List<ClassEvent>> fetchEvents();
}

class MockEventRepository implements EventRepository {
  @override
  Future<List<ClassEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      // Sự kiện 1: Đã đăng ký
      ClassEvent(
        id: '1',
        title: 'Hội thảo Khởi nghiệp 2024',
        description: 'Hội thảo về xu hướng khởi nghiệp và cơ hội việc làm',
        date: '15/12/2024',
        time: '14:00 - 16:00',
        location: 'Hội trường A',
        isMandatory: true,
        status: EventStatus.registered,
      ),
      // Sự kiện 2: Đã tham gia
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
}
