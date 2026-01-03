import 'package:intl/intl.dart'; // Nếu chưa có, hãy thêm intl vào pubspec.yaml để format ngày giờ chuẩn hơn

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

  // Thời gian diễn ra sự kiện
  final DateTime startTime;
  final DateTime? endTime;

  // Thời gian chốt đăng ký (Quan trọng cho logic Mở/Đóng)
  final DateTime registrationDeadline;

  final String location;
  final bool isMandatory;
  final List<Student> participants;
  final List<Student> nonParticipants;
  final List<Student> unconfirmed;

  ClassEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startTime,
    this.endTime,
    required this.registrationDeadline,
    required this.location,
    this.isMandatory = false,
    this.participants = const [],
    this.nonParticipants = const [],
    this.unconfirmed = const [],
  });

  // --- GETTERS LOGIC ---

  // 1. Logic quyết định Mở hay Đóng: So sánh hiện tại với Deadline
  bool get isOpen {
    final now = DateTime.now();
    return now.isBefore(registrationDeadline);
  }

  // 2. Format Ngày sự kiện (VD: 20/11/2025)
  String get dateDisplay {
    return "${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}";
  }

  // 3. Format Giờ sự kiện (VD: 07:00 - 09:00)
  String get timeDisplay {
    final startStr =
        "${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}";
    if (endTime != null) {
      final endStr =
          "${endTime!.hour.toString().padLeft(2, '0')}:${endTime!.minute.toString().padLeft(2, '0')}";
      return "$startStr - $endStr";
    }
    return startStr;
  }

  // 4. Format Hạn đăng ký để hiển thị UI (VD: 17:00 19/11/2025)
  String get deadlineDisplay {
    return "${registrationDeadline.hour.toString().padLeft(2, '0')}:${registrationDeadline.minute.toString().padLeft(2, '0')} ${registrationDeadline.day}/${registrationDeadline.month}/${registrationDeadline.year}";
  }

  // 5. Thời gian còn lại để đăng ký (Dùng cho đếm ngược)
  Duration get timeRemainingToRegister =>
      registrationDeadline.difference(DateTime.now());

  int get registeredCount => participants.length;
  int get unregisteredCount => nonParticipants.length + unconfirmed.length;
  int get totalCount =>
      participants.length + nonParticipants.length + unconfirmed.length;
  double get progress => totalCount == 0 ? 0 : registeredCount / totalCount;

  // --- FACTORY ---
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

    return ClassEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      // Parse và chuyển về Local Time
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time']).toLocal()
          : null,

      // Parse Registration Deadline (Có fallback nếu DB cũ chưa có dữ liệu này)
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline']).toLocal()
          : DateTime.parse(
              json['start_time'],
            ).toLocal(), // Mặc định bằng start_time nếu null

      location: json['location'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      participants: participants,
      nonParticipants: nonParticipants,
      unconfirmed: unconfirmed,
    );
  }

  // --- TO JSON ---
  Map<String, dynamic> toJson(String classId) {
    final Map<String, dynamic> result = {
      'title': title,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'registration_deadline': registrationDeadline
          .toIso8601String(), // Lưu deadline
      'location': location,
      'is_mandatory': isMandatory,
    };

    if (classId.isNotEmpty) {
      result['class_id'] = classId;
    }

    if (endTime != null) {
      result['end_time'] = endTime!.toIso8601String();
    } else {
      result['end_time'] = null;
    }

    return result;
  }

  // CopyWith
  ClassEvent copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    DateTime? registrationDeadline,
    String? location,
    bool? isMandatory,
    List<Student>? participants,
    List<Student>? nonParticipants,
    List<Student>? unconfirmed,
  }) {
    return ClassEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      location: location ?? this.location,
      isMandatory: isMandatory ?? this.isMandatory,
      participants: participants ?? this.participants,
      nonParticipants: nonParticipants ?? this.nonParticipants,
      unconfirmed: unconfirmed ?? this.unconfirmed,
    );
  }
}
