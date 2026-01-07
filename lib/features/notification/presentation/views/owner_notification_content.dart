import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/create_notification_section.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/notification_card.dart';
import '../view_models/notification_view_model.dart';

class OwnerNotificationContent extends ConsumerStatefulWidget {
  final String classId; // truyền classId vào để lọc theo lớp

  const OwnerNotificationContent({
    super.key,
    required this.classId,
  });

  @override
  ConsumerState<OwnerNotificationContent> createState() =>
      _OwnerNotificationContentState();
}

class _OwnerNotificationContentState extends ConsumerState<OwnerNotificationContent> {
  int _tabIndex = 0;

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(notificationListProvider(widget.classId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const NotificationHeader(),
          const SizedBox(height: 16),
          NotificationTabs(
            currentIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: 16),

          asyncList.when(
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 24),
              child: CircularProgressIndicator(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Text('Lỗi: $e'),
            ),
            data: (list) {
              final filtered = _tabIndex == 1
                  ? list.where((n) => !n.isRead).toList()
                  : list;

              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text('Chưa có thông báo nào.'),
                );
              }

              return Column(
                children: [
                  for (final n in filtered)
                    NotificationCard(
                      icon: n.icon,
                      iconBg: n.iconBg,
                      title: n.title,
                      content: n.body,
                      time: _formatTime(n.createdAt),
                      unread: !n.isRead,
                    ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),
          const CreateNotificationSection(),
        ],
      ),
    );
  }
}
