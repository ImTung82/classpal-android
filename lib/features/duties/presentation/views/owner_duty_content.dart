import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/duty_view_model.dart';
import '../widgets/score_board_item.dart';
import '../widgets/active_duty_card.dart';

class OwnerDutyContent extends ConsumerWidget {
  const OwnerDutyContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoresAsync = ref.watch(scoreBoardProvider);
    final activeDutiesAsync = ref.watch(activeDutiesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Quản lý trực nhật", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Phân công và theo dõi nhiệm vụ xoay vòng", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          // Nút Tạo nhiệm vụ
          SizedBox(
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text("Tạo nhiệm vụ"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.trophy, color: Color(0xFFD97706), size: 20),
                    const SizedBox(width: 8),
                    Text("Bảng Vàng", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const SizedBox(height: 16),
                scoresAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Text('Lỗi: $e'),
                  data: (scores) => Column(children: scores.map((s) => ScoreBoardItem(score: s)).toList()),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section Nhiệm vụ đang hoạt động
          Text("Nhiệm vụ đang hoạt động", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180, // Chiều cao cố định cho list ngang
            child: activeDutiesAsync.when(
              loading: () => const SizedBox(),
              error: (e, s) => const SizedBox(),
              data: (duties) => ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: duties.length,
                itemBuilder: (context, index) => ActiveDutyCard(task: duties[index]),
              ),
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}