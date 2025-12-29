enum EventStatus { upcoming, registered, participated }

class Student {
  final String id;
  final String name;
  final String? avatarUrl;

  Student({required this.id, required this.name, this.avatarUrl});

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['user_id'] ?? '',
      name: json['profiles']?['full_name'] ?? 'Unknown',
      avatarUrl: json['profiles']?['avatar_url'],
    );
  }
}

class ClassEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String time;
  final String location;
  final bool isMandatory;
  final EventStatus status;
  final bool isOpen;
  final List<Student> participants;
  final List<Student> nonParticipants;
  final List<Student> unconfirmed;

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
    this.participants = const [],
    this.nonParticipants = const [],
    this.unconfirmed = const [],
  });

  // --- Getters ---
  int get registeredCount => participants.length;
  int get unregisteredCount => unconfirmed.length;
  int get totalCount =>
      participants.length + nonParticipants.length + unconfirmed.length;
  double get progress => totalCount == 0 ? 0 : registeredCount / totalCount;

  // Factory từ Supabase JSON
  factory ClassEvent.fromJson(Map<String, dynamic> json) {
    final participants = <Student>[];
    final nonParticipants = <Student>[];
    final unconfirmed = <Student>[];

    if (json['event_participants'] != null) {
      for (var participant in json['event_participants']) {
        final student = Student.fromJson(participant);
        final status = participant['status'] as String?;

        if (status == 'joined') {
          participants.add(student);
        } else if (status == 'not_joined') {
          nonParticipants.add(student);
        } else {
          unconfirmed.add(student);
        }
      }
    }

    // Parse start_time
    final startTime = DateTime.parse(json['start_time']).toLocal();
    final dateStr =
        "${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}";

    String timeStr =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    
    // Parse end_time nếu có
    DateTime? endTime;
    if (json['end_time'] != null) {
      endTime = DateTime.parse(json['end_time']).toLocal();
      timeStr +=
          " - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
    }

    // --- LOGIC QUAN TRỌNG: XÁC ĐỊNH IS_OPEN ---
    // Mặc định là mở. Nếu có end_time và thời điểm hiện tại đã vượt quá end_time -> Đóng.
    // Hoặc nếu bạn quy ước "có end_time tức là đã đóng thủ công" thì dùng logic dưới đây.
    bool calculatedIsOpen = true;
    if (endTime != null) {
        // Logic 1: Đóng nếu quá hạn
        if (DateTime.now().isAfter(endTime)) {
            calculatedIsOpen = false;
        }
        // Logic 2 (theo yêu cầu của bạn): Nếu có end_time thì coi như đã đóng (để lưu dấu mốc đóng)
        // calculatedIsOpen = false; 
    }

    return ClassEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: dateStr,
      time: timeStr,
      location: json['location'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      status: EventStatus.upcoming,
      isOpen: calculatedIsOpen,
      participants: participants,
      nonParticipants: nonParticipants,
      unconfirmed: unconfirmed,
    );
  }

  // Convert sang JSON
  Map<String, dynamic> toJson(String classId) {
    // Parse ngày tháng từ chuỗi hiển thị về DateTime để lưu DB
    final dateParts = date.split('/');
    final day = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final year = int.parse(dateParts[2]);

    final timeParts = time.split(' - ');
    final startTimeParts = timeParts[0].split(':');
    final startHour = int.parse(startTimeParts[0]);
    final startMinute = int.parse(startTimeParts[1]);

    final startTime = DateTime(year, month, day, startHour, startMinute);

    final result = {
      'class_id': classId,
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'location': location,
      'is_mandatory': isMandatory,
      // Lưu ý: Không gửi is_open, logic đóng mở xử lý ở Repository
    };

    // Chỉ gửi end_time nếu chuỗi thời gian có phần kết thúc (cho trường hợp update thông tin cơ bản)
    // Còn việc Đóng/Mở sự kiện sẽ được xử lý riêng.
    if (timeParts.length > 1) {
      final endTimeParts = timeParts[1].split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);
      final endTime = DateTime(year, month, day, endHour, endMinute);
      result['end_time'] = endTime.toIso8601String();
    }

    return result;
  }

  // CopyWith
  ClassEvent copyWith({
    String? id,
    String? title,
    String? description,
    String? date,
    String? time,
    String? location,
    bool? isMandatory,
    EventStatus? status,
    bool? isOpen,
    List<Student>? participants,
    List<Student>? nonParticipants,
    List<Student>? unconfirmed,
  }) {
    return ClassEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      isMandatory: isMandatory ?? this.isMandatory,
      status: status ?? this.status,
      isOpen: isOpen ?? this.isOpen,
      participants: participants ?? this.participants,
      nonParticipants: nonParticipants ?? this.nonParticipants,
      unconfirmed: unconfirmed ?? this.unconfirmed,
    );
  }
}