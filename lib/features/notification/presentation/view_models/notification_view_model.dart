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

/// Fetch list notifications cho 1 class cụ thể
final notificationListProvider =
    FutureProvider.family<List<NotificationModel>, String>((ref, classId) async {
  final client = ref.read(supabaseProvider);
  final user = client.auth.currentUser;
  if (user == null) return [];

  final repo = ref.read(notificationRepositoryProvider);
  return repo.fetchNotificationsForClass(classId: classId, userId: user.id);
});
