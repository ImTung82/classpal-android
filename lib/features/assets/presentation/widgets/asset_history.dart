import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../view_models/asset_view_model.dart';
import 'asset_history_item.dart';

void showAssetHistoryOverlay({
  required BuildContext context,
  required String classId,
  required String assetId,
  required String assetName,
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'AssetHistory',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) {
      return AssetHistoryOverlay(
        classId: classId,
        assetId: assetId,
        assetName: assetName,
      );
    },
  );
}

class AssetHistoryOverlay extends ConsumerWidget {
  final String classId;
  final String assetId;
  final String assetName;

  const AssetHistoryOverlay({
    super.key,
    required this.classId,
    required this.assetId,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      assetHistoryByAssetProvider(
        (classId: classId, assetId: assetId),
      ),
    );

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lịch sử: $assetName',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              historyAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: Text('Chưa có lịch sử')),
                    );
                  }

                  return SizedBox(
                    height: 300,
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        return HistoryItem(history: list[i]);
                      },
                    ),
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) =>
                    Text('Lỗi tải lịch sử: $e'),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 45,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F4F6),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
