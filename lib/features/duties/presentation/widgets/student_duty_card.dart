import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/duty_models.dart';
import '../view_models/duty_view_model.dart';

class StudentDutyCard extends ConsumerWidget {
  final DutyTask task;
  final String classId;

  const StudentDutyCard({super.key, required this.task, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(dutyControllerProvider).isLoading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFFA855F7)], // Blue to Purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.dateRange.split('•').first.trim(),
                style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.users,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.title,
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            task.description,
            style: GoogleFonts.roboto(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(dutyControllerProvider.notifier)
                          .markAsCompleted(
                            classId: classId,
                            dutyId: task.id,
                            onSuccess: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Đã đánh dấu hoàn thành"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            onError: (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            },
                          );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF3B82F6),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      "Đánh dấu hoàn thành",
                      style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
