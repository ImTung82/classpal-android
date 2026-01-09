import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../view_models/event_view_model.dart'; // Đảm bảo đường dẫn này đúng với file chứa studentEventsProvider
import '../widgets/student_event_card.dart';

class StudentEventContent extends ConsumerWidget {
  final String classId;

  const StudentEventContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Gọi Provider lấy danh sách sự kiện cho sinh viên theo classId
    final eventsAsync = ref.watch(studentEventsProvider(classId));

    // [MỚI] Hàm refresh
    Future<void> refreshData() async {
      await ref.refresh(studentEventsProvider(classId).future);
    }

    return RefreshIndicator(
      onRefresh: refreshData,
      color: const Color(0xFF155DFC), // [THÊM] Màu xanh
      child: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Lỗi tải sự kiện: $err',
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: Colors.red),
            ),
          ),
        ),
        data: (events) {
          if (events.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.event_note,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Chưa có sự kiện nào trong lớp này",
                        style: GoogleFonts.roboto(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return StudentEventCard(event: event, classId: classId);
            },
          );
        },
      ),
    );
  }
}
