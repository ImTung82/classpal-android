import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

    // refresh list
    ref.invalidate(notificationListProvider(classId));
  };
});