import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NotificationModel {
  final String id;
  final String userId;
  final String? classId;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    this.classId,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      classId: json['class_id'] as String?,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      type: (json['type'] as String?) ?? 'general',
      isRead: (json['is_read'] as bool?) ?? false,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  // ===== UI mapping để giữ giao diện cũ =====
  IconData get icon {
    switch (type) {
      case 'event_reminder':
        return LucideIcons.calendar;
      case 'duty_reminder':
        return LucideIcons.clipboardList;
      case 'fund_reminder':
        return LucideIcons.wallet;
      case 'general':
        return LucideIcons.info;
      default:
        return LucideIcons.bell;
    }
  }

  Color get iconBg {
    switch (type) {
      case 'event_reminder':
        return const Color(0xFFFFEDD5);
      case 'duty_reminder':
        return const Color(0xFFDBEAFE);
      case 'fund_reminder':
        return const Color(0xFFDCFCE7);
      case 'general':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}
