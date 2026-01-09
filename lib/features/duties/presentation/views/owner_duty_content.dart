import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/duty_view_model.dart';
import '../widgets/score_board_item.dart';
import '../widgets/active_duty_card.dart';
import '../widgets/create_duty_dialog.dart';
import '../../data/models/duty_models.dart';

class OwnerDutyContent extends ConsumerWidget {
  final String classId;

  const OwnerDutyContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(scoreBoardProvider(classId));
    final activeDutiesAsync = ref.watch(activeDutiesProvider(classId));
    // Sử dụng provider mới để lấy duy nhất dữ liệu tuần sau
    final nextWeekDutiesAsync = ref.watch(nextWeekDutiesProvider(classId));

    // Hàm refresh
    Future<void> refreshData() async {
      await Future.wait([
        ref.refresh(scoreBoardProvider(classId).future),
        ref.refresh(activeDutiesProvider(classId).future),
        ref.refresh(nextWeekDutiesProvider(classId).future),
      ]);
    }

    // Bọc RefreshIndicator
    return RefreshIndicator(
      onRefresh: refreshData,
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        // Cho phép cuộn để refresh ngay cả khi ít nội dung
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quản lý trực nhật",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Phân công và theo dõi nhiệm vụ xoay vòng",
              style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // Nút Tạo nhiệm vụ
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => CreateDutyDialog(classId: classId),
                  );
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text("Tạo nhiệm vụ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Bảng Vàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        LucideIcons.trophy,
                        color: Color(0xFFD97706),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Bảng Vàng",
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  scoresAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, s) => Text('Lỗi: $e'),
                    data: (scores) => Column(
                      children: scores
                          .map((s) => ScoreBoardItem(score: s))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Nhiệm vụ tuần này
            Text(
              "Nhiệm vụ tuần này",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildDutyHorizontalList(activeDutiesAsync, classId),

            const SizedBox(height: 24),

            // Section 2: Nhiệm vụ tuần sau (Dữ liệu đã được lọc lte/gte trong Repository)
            Text(
              "Nhiệm vụ tuần sau",
              style: GoogleFonts.roboto(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildDutyHorizontalList(nextWeekDutiesAsync, classId),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDutyHorizontalList(
    AsyncValue<List<DutyTask>> dutiesAsync,
    String classId,
  ) {
    return SizedBox(
      height: 180,
      child: dutiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Lỗi: $e")),
        data: (duties) {
          if (duties.isEmpty) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade100,
                  style: BorderStyle.solid,
                ),
              ),
              child: Text(
                "Chưa có nhiệm vụ nào",
                style: GoogleFonts.roboto(color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: duties.length,
            itemBuilder: (context, index) =>
                ActiveDutyCard(task: duties[index], classId: classId),
          );
        },
      ),
    );
  }
}
