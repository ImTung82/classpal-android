import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../widgets/create_notification_section.dart';
import '../widgets/notification_header.dart';
import '../widgets/notification_tabs.dart';
import '../widgets/notification_card.dart';

class OwnerNotificationContent extends StatefulWidget {
  const OwnerNotificationContent({super.key});

  @override
  State<OwnerNotificationContent> createState() =>
      _OwnerNotificationContentState();
}

class _OwnerNotificationContentState extends State<OwnerNotificationContent> {
  int _tabIndex = 0; 

  @override
  Widget build(BuildContext context) {
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
          NotificationCard(
            icon: LucideIcons.calendar,
            iconBg: const Color(0xFFFFEDD5),
            title: "Nhắc nhở sự kiện",
            content:
                "Sinh nhật lớp sẽ diễn ra vào ngày mai (15/12). Đã có 28/35 sinh viên đăng ký tham gia.",
            time: "2 giờ trước",
            unread: true,
          ),

          NotificationCard(
            icon: LucideIcons.clipboardList,
            iconBg: const Color(0xFFDBEAFE),
            title: "Lịch trực nhật tuần mới",
            content:
                "Tổ 3 sẽ trực nhật từ ngày 16/12 đến 22/12. Nhớ chuẩn bị đầy đủ.",
            time: "5 giờ trước",
            unread: true,
          ),

          if (_tabIndex == 0)
            NotificationCard(
              icon: LucideIcons.info,
              iconBg: const Color(0xFFF3F4F6),
              title: "Thông báo từ lớp trưởng",
              content:
                  "Cuộc họp lớp sẽ diễn ra vào 14h chiều thứ 6 tuần này tại phòng A201.",
              time: "4 ngày trước",
              unread: false,
            ),

          const SizedBox(height: 16),
          const CreateNotificationSection(),
        ],
      ),
    );
  }
}
