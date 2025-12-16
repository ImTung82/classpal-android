import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/owner_event_view_model.dart';
import '../widgets/owner_event_card.dart';

class OwnerEventContent extends ConsumerWidget {
  const OwnerEventContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(ownerEventsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Quản lý sự kiện",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Tạo sự kiện và theo dõi đăng ký",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          // Nút Tạo sự kiện (Full width - Xanh dương đậm)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                // Logic mở dialog tạo sự kiện
              },
              icon: const Icon(LucideIcons.plus, size: 20),
              label: const Text("Tạo sự kiện mới"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF155DFC), // Màu xanh từ Figma
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Danh sách sự kiện
          eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Text('Lỗi: $err', style: GoogleFonts.roboto()),
            data: (events) {
              if (events.isEmpty)
                return const Center(child: Text("Chưa có sự kiện nào"));
              return Column(
                children: events
                    .map((event) => OwnerEventCard(event: event))
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
