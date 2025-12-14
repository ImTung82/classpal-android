import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Import ViewModels
import '../view_models/duty_view_model.dart';
import '../../../dashboard/presentation/view_models/dashboard_view_model.dart'; // Lấy viewmodel thành viên từ dashboard

// Import Widgets
import '../widgets/student_duty_card.dart';
import '../widgets/upcoming_duty_item.dart';
import '../../../dashboard/presentation/widgets/group_member_item.dart'; // Tái sử dụng

class StudentDutyContent extends ConsumerWidget {
  const StudentDutyContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myDutyAsync = ref.watch(myDutyProvider);
    final upcomingAsync = ref.watch(upcomingDutiesProvider);
    final membersAsync = ref.watch(groupMembersProvider); // Re-use từ dashboard

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Nhiệm vụ của bạn", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Lịch trực và nhiệm vụ được giao", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 16),

          // Main Card
          myDutyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => const SizedBox(),
            data: (task) => task != null ? StudentDutyCard(task: task) : const Text("Không có nhiệm vụ"),
          ),
          
          const SizedBox(height: 24),

          // List thành viên
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Thành viên Tổ 3", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                membersAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                  data: (members) => Column(children: members.map((m) => GroupMemberItem(member: m)).toList()),
                )
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Lịch sắp tới
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lịch sắp tới", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                upcomingAsync.when(
                  loading: () => const SizedBox(),
                  error: (e, s) => const SizedBox(),
                  data: (tasks) => Column(children: tasks.map((t) => UpcomingDutyItem(task: t)).toList()),
                )
              ],
            ),
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }
}