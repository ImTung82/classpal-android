import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../view_models/owner_event_view_model.dart';
import '../widgets/owner_event_card.dart';
import '../widgets/create_event_dialog.dart';
import '../../data/models/event_models.dart';

class OwnerEventContent extends ConsumerStatefulWidget {
  final String classId;

  const OwnerEventContent({super.key, required this.classId});

  @override
  ConsumerState<OwnerEventContent> createState() => _OwnerEventContentState();
}

class _OwnerEventContentState extends ConsumerState<OwnerEventContent> {
  void _showSnackbar(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _showCreateEventDialog() async {
    final result = await showDialog<ClassEvent>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const CreateEventDialog();
      },
    );

    if (result != null && mounted) {
      ref
          .read(eventControllerProvider.notifier)
          .createEvent(
            classId: widget.classId,
            event: result,
            onSuccess: () =>
                _showSnackbar('Tạo sự kiện thành công!', Colors.green),
            onError: (e) => _showSnackbar('Lỗi: $e', Colors.red),
          );
    }
  }

  // Thêm method helper để force refresh
  void _refreshEvents() {
    ref.invalidate(ownerEventsProvider(widget.classId));
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(ownerEventsProvider(widget.classId));
    final isLoading = ref.watch(eventControllerProvider).isLoading;

    return Stack(
      children: [
        // Thêm RefreshIndicator để có thể pull-to-refresh
        RefreshIndicator(
          onRefresh: () async {
            _refreshEvents();
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: SingleChildScrollView(
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

                // Nút Tạo sự kiện
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _showCreateEventDialog,
                    icon: const Icon(LucideIcons.plus, size: 20),
                    label: const Text("Tạo sự kiện mới"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF155DFC),
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
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                          .map(
                            (event) => OwnerEventCard(
                              event: event,
                              classId: widget.classId,
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),

        // Loading overlay
        if (isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
