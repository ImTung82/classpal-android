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

    // Parse end_time nếu có (đây là giờ kết thúc dự kiến, không phải closed timestamp)
    if (json['end_time'] != null) {
      try {
        final endTime = DateTime.parse(json['end_time']).toLocal();
        timeStr +=
            " - ${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        print('⚠️ Lỗi parse end_time: $e');
      }
    }

    // --- LOGIC ĐÚNG: isOpen chỉ phụ thuộc vào end_time có null hay không ---
    // end_time == null => Sự kiện đang mở
    // end_time != null => Sự kiện đã đóng (đã có người bấm "Đã đóng" và lưu)
    bool calculatedIsOpen = json['end_time'] == null;

    return ClassEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: dateStr,
      time: timeStr,
      location: json['location'] ?? '',
      isMandatory: json['is_mandatory'] ?? false, // Boolean từ DB
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
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'location': location,
      'is_mandatory': isMandatory, // Boolean
    };

    // Chỉ thêm class_id nếu không rỗng (cho trường hợp tạo mới)
    if (classId.isNotEmpty) {
      result['class_id'] = classId;
    }

    // Nếu có giờ kết thúc dự kiến trong chuỗi time, lưu vào DB
    // CHÚ Ý: Đây là giờ kết thúc DỰ KIẾN, không phải closed timestamp
    // Closed timestamp sẽ được xử lý riêng ở Repository
    if (timeParts.length > 1) {
      final endTimeParts = timeParts[1].trim().split(':');
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
