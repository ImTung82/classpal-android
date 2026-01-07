import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/notification_header.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/notification_card.dart';
import '../view_models/notification_view_model.dart';

class StudentNotificationContent extends ConsumerStatefulWidget {
  final String classId;

  const StudentNotificationContent({super.key, required this.classId});

  @override
  ConsumerState<StudentNotificationContent> createState() =>
      _StudentNotificationContentState();
}

class _StudentNotificationContentState
    extends ConsumerState<StudentNotificationContent> {
  int _tabIndex = 0;

  String _formatTime(DateTime dt) {
    final localTime = dt.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localTime);

    if (diff.inSeconds < 10) return 'Vừa xong';
    if (diff.inMinutes < 1) return '${diff.inSeconds} giây trước';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(notificationListProvider(widget.classId));
    ref.watch(notificationRealtimeProvider(widget.classId));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: asyncList.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Lỗi: $e'),
        data: (list) {
          final unreadCount = list.where((n) => !n.isRead).length;
          final filtered = _tabIndex == 1
              ? list.where((n) => !n.isRead).toList()
              : list;

          return Column(
            children: [
              NotificationHeader(
                onMarkAllRead: () {
                  final markAll = ref.read(markAllNotificationsReadProvider);
                  markAll(widget.classId);
                },
              ),

              const SizedBox(height: 16),

              /// Tabs
              NotificationTabs(
                currentIndex: _tabIndex,
                totalCount: list.length,
                unreadCount: unreadCount,
                onChanged: (i) => setState(() => _tabIndex = i),
              ),

              const SizedBox(height: 16),

              if (filtered.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Text('Chưa có thông báo nào.'),
                )
              else
                Column(
                  children: [
                    for (final n in filtered)
                      GestureDetector(
                        onTap: n.isRead
                            ? null
                            : () {
                                final markRead = ref.read(
                                  markNotificationReadProvider,
                                );
                                markRead(
                                  notificationId: n.id,
                                  classId: widget.classId,
                                );
                              },
                        child: NotificationCard(
                          icon: n.icon,
                          iconBg: n.iconBg,
                          title: n.title,
                          content: n.body,
                          time: _formatTime(n.createdAt),
                          unread: !n.isRead,
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}
