import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../../data/models/notification_models.dart';
import '../../data/repositories/notification_repository.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository(ref.read(supabaseProvider));
});


final notificationListProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, classId) async {
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final repo = ref.read(notificationRepositoryProvider);
  return repo.fetchNotificationsForClass(classId: classId, userId: user.id);
});

final markNotificationReadProvider = Provider((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  final client = ref.read(supabaseProvider);

  return ({
    required String notificationId,
    required String classId,
  }) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await repo.markAsRead(
      notificationId: notificationId,
      userId: user.id,
    );

    ref.invalidate(notificationListProvider(classId));
  };
});

final markAllNotificationsReadProvider = Provider((ref) {
  final repo = ref.read(notificationRepositoryProvider);
  final client = ref.read(supabaseProvider);

  return (String classId) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await repo.markAllAsRead(
      userId: user.id,
      classId: classId,
    );

    ref.invalidate(notificationListProvider(classId));
  };
});

final unreadCountProvider =
    Provider.family<int, List<NotificationModel>>((ref, list) {
  return list.where((n) => !n.isRead).length;
});

final createNotificationProvider = Provider((ref) {
  final repo = ref.read(notificationRepositoryProvider);

  return ({
    required String classId,
    required String title,
    required String body,
    required String type,
  }) async {
    await repo.createNotificationForClass(
      classId: classId,
      title: title,
      body: body,
      type: type,
    );

    ref.invalidate(notificationListProvider(classId));
  };
});

final deleteNotificationProvider = Provider(
  (ref) {
    final repo = ref.read(notificationRepositoryProvider);

    return (String notificationId, String classId) async {
      await repo.deleteNotification(notificationId);
      ref.invalidate(notificationListProvider(classId));
    };
  },
);


final notificationRealtimeProvider =
    Provider.family<void, String>((ref, classId) {
  final client = Supabase.instance.client;

  final channel = client.channel('notifications-realtime-$classId');

  channel
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'notifications',
        callback: (payload) {

          final newRow = payload.newRecord;
          final oldRow = payload.oldRecord;

          if (newRow != null && newRow['class_id'] == classId) {
            ref.invalidate(notificationListProvider(classId));
          } else if (oldRow != null && oldRow['class_id'] == classId) {
            ref.invalidate(notificationListProvider(classId));
          } else {
            print('❌ Not match class_id');
          }
        },
      )
      .subscribe();

  ref.onDispose(() {
    client.removeChannel(channel);
  });
});

final unreadNotificationCountProvider =
    Provider.family<int, String>((ref, classId) {
  final asyncList =
      ref.watch(notificationListProvider(classId));

  return asyncList.maybeWhen(
    data: (list) => list.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});




