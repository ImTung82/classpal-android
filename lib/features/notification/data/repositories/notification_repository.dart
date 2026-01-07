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
}
