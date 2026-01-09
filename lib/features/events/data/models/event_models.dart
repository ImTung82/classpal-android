import 'package:intl/intl.dart';

enum EventStatus { upcoming, registered, participated }

class Student {
  final String id;
  final String name;
  final String? avatarUrl;
  final String studentCode; // Mã sinh viên
  final String teamName; // Tên tổ/đội

  Student({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.studentCode,
    required this.teamName,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];

    return Student(
      id: json['user_id'] ?? '',
      name: profile?['full_name'] ?? 'Unknown',
      avatarUrl: profile?['avatar_url'],
      
      // [FIX] Lấy dữ liệu bơm từ Repository, fallback về N/A
      studentCode: json['student_code'] ?? 'N/A',
      teamName: json['team_name'] ?? 'Chưa phân tổ',
    );
  }
}

class ClassEvent {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
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

  // 1. Kiểm tra còn mở đăng ký không
  bool get isOpen {
    final now = DateTime.now();
    return now.isBefore(registrationDeadline);
  }

  // 2. [BỊ THIẾU LÚC NÃY] Thời gian còn lại để đăng ký
  Duration get timeRemainingToRegister => registrationDeadline.difference(DateTime.now());

  // 3. Hiển thị ngày
  String get dateDisplay => DateFormat('dd/MM/yyyy').format(startTime);

  // 4. Hiển thị giờ (Ví dụ: 07:00 - 09:00 hoặc 07:00)
  String get timeDisplay {
    final startStr = DateFormat('HH:mm').format(startTime);
    if (endTime != null) {
      final endStr = DateFormat('HH:mm').format(endTime!);
      return "$startStr - $endStr";
    }
    return startStr;
  }

  // 5. Hiển thị hạn đăng ký
  String get deadlineDisplay => DateFormat('HH:mm dd/MM/yyyy').format(registrationDeadline);

  // 6. Các chỉ số thống kê
  int get registeredCount => participants.length;
  int get unregisteredCount => nonParticipants.length + unconfirmed.length;
  int get totalCount => participants.length + nonParticipants.length + unconfirmed.length;
  
  // 7. Tiến độ đăng ký (0.0 -> 1.0)
  double get progress => totalCount == 0 ? 0 : registeredCount / totalCount;

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
          unconfirmed.add(student); // pending
        }
      }
    }

    return ClassEvent(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startTime: DateTime.parse(json['start_time']).toLocal(),
      endTime: json['end_time'] != null ? DateTime.parse(json['end_time']).toLocal() : null,
      registrationDeadline: json['registration_deadline'] != null
          ? DateTime.parse(json['registration_deadline']).toLocal()
          : DateTime.parse(json['start_time']).toLocal(),
      location: json['location'] ?? '',
      isMandatory: json['is_mandatory'] ?? false,
      participants: participants,
      nonParticipants: nonParticipants,
      unconfirmed: unconfirmed,
    );
  }

  Map<String, dynamic> toJson(String classId) {
    final Map<String, dynamic> result = {
      'title': title,
      'description': description,
      'start_time': startTime.toUtc().toIso8601String(),
      'registration_deadline': registrationDeadline.toUtc().toIso8601String(),
      'location': location,
      'is_mandatory': isMandatory,
    };
    if (classId.isNotEmpty) result['class_id'] = classId;
    if (endTime != null) result['end_time'] = endTime!.toUtc().toIso8601String();
    else result['end_time'] = null;
    return result;
  }

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