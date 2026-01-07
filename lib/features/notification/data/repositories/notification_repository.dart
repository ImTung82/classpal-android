import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_models.dart';

class NotificationRepository {
  final SupabaseClient _client;
  NotificationRepository(this._client);

  Future<bool> isUserActiveMemberOfClass({
    required String classId,
    required String userId,
  }) async {
    final res = await _client
        .from('class_members')
        .select('id')
        .eq('class_id', classId)
        .eq('user_id', userId)
        .eq('is_active', true)
        .limit(1);

    return (res as List).isNotEmpty;
  }

  Future<List<NotificationModel>> fetchNotificationsForClass({
    required String classId,
    required String userId,
  }) async {
    final isMember = await isUserActiveMemberOfClass(
      classId: classId,
      userId: userId,
    );

    if (!isMember) return [];

    final res = await _client
        .from('notifications')
        .select()
        .eq('class_id', classId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (res as List)
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead({
    required String notificationId,
    required String userId,
  }) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notificationId)
        .eq('user_id', userId);
  }

  Future<void> markAllAsRead({
    required String userId,
    required String classId,
  }) async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('class_id', classId)
        .eq('is_read', false);
  }

  Future<void> createNotificationForClass({
    required String classId,
    required String title,
    required String body,
    required String type,
  }) async {
    
    final membersRes = await _client
        .from('class_members')
        .select('user_id')
        .eq('class_id', classId)
        .eq('is_active', true);

    final members = (membersRes as List)
        .map((e) => e['user_id'] as String)
        .toList();

    if (members.isEmpty) return;


    final rows = members.map((userId) {
      return {
        'user_id': userId,
        'class_id': classId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      };
    }).toList();

    await _client.from('notifications').insert(rows);
  }

  Future<void> sendFundReminderToUsers({
    required String classId,
    required String campaignTitle,
    required int amountPerPerson,
    required List<String> userIds,
  }) async {
    if (userIds.isEmpty) return;

    final rows = userIds.map((uid) {
      return {
        'user_id': uid,
        'class_id': classId,
        'title': 'Nhắc nhở nộp quỹ',
        'body':
            'Bạn chưa nộp quỹ "$campaignTitle" '
            '(${amountPerPerson}đ). Vui lòng hoàn thành sớm.',
        'type': 'fund_reminder',
        'is_read': false,
      };
    }).toList();

    await _client.from('notifications').insert(rows);
  }
}
