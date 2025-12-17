import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/owner_event_view_model.dart';
import '../widgets/owner_event_card.dart';
import '../widgets/create_event_dialog.dart';

class OwnerEventContent extends ConsumerWidget {
  const OwnerEventContent({super.key});

  // --- HÀM MỞ DIALOG (Đã sửa lỗi cú pháp) ---
  Future<void> _showCreateEventDialog(BuildContext context) async {
    // Gọi Dialog và chờ kết quả trả về
    final result = await showDialog(
      context: context,
      barrierDismissible: false, // Bắt buộc bấm Hủy hoặc Tạo để đóng
      builder: (BuildContext context) {
        return const CreateEventDialog();
      },
    );

    // Kiểm tra kết quả sau khi đóng Dialog
    if (result == true) {
      if (!context.mounted) return;

      // Hiện thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tạo sự kiện thành công!'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // TODO: Gọi hàm reload danh sách sự kiện nếu cần
      // ví dụ: ref.refresh(ownerEventsProvider);
    }
  }

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
                // [ĐÃ SỬA] Gọi hàm mở dialog tại đây
                _showCreateEventDialog(context);
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
              if (events.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text("Chưa có sự kiện nào"),
                  ),
                );
              }
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
