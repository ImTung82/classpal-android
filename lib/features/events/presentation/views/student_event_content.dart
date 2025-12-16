import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart'; // [IMPORT FONT]
import '../view_models/event_view_model.dart';
import '../widgets/student_event_card.dart';

class StudentEventContent extends ConsumerWidget {
  const StudentEventContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [CẬP NHẬT] Font & Size giống hệt Teams (StudentTeamContent)
          Text(
            "Sự kiện",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Đăng ký tham gia các sự kiện lớp",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(
            height: 16,
          ), // Giảm khoảng cách từ 24 xuống 16 cho giống Teams

          eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Text('Lỗi: $err', style: GoogleFonts.roboto()),
            data: (events) {
              if (events.isEmpty) {
                return Center(
                  child: Text(
                    "Chưa có sự kiện nào",
                    style: GoogleFonts.roboto(color: Colors.grey),
                  ),
                );
              }
              return Column(
                children: events
                    .map((event) => StudentEventCard(event: event))
                    .toList(),
              );
            },
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
