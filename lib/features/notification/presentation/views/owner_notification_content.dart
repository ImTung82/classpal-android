import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/create_notification_section.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/notification_card.dart';
import '../view_models/notification_view_model.dart';

class OwnerNotificationContent extends ConsumerStatefulWidget {
  final String classId; // truyền classId vào để lọc theo lớp

  const OwnerNotificationContent({super.key, required this.classId});

  @override
  ConsumerState<OwnerNotificationContent> createState() =>
      _OwnerNotificationContentState();
}

class _OwnerNotificationContentState
    extends ConsumerState<OwnerNotificationContent> {
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
                          onDelete: () async {
                            final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text(
                                  'Xóa thông báo',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                content: const Text(
                                  'Bạn có chắc chắn muốn xóa thông báo này?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text(
                                      'Hủy',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: const Text(
                                      'Xóa',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (ok == true) {
                              final delete = ref.read(
                                deleteNotificationProvider,
                              );
                              await delete(n.id, widget.classId);

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Đã xóa thông báo thành công',
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 16),
              CreateNotificationSection(classId: widget.classId),
            ],
          );
        },
      ),
    );
  }
}
