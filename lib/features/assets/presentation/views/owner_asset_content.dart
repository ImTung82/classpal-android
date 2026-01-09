import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/asset_view_model.dart';
import '../widgets/asset_card.dart';
import '../widgets/asset_history_item.dart';
import '../widgets/small_stat_card.dart';
import '../widgets/add_asset.dart';
import '../widgets/edit_asset.dart';
import '../widgets/delete_asset.dart';
import '../widgets/asset_history.dart';

class OwnerAssetContent extends ConsumerWidget {
  final String classId;
  const OwnerAssetContent({super.key, required this.classId});
  void _showSnack(
    BuildContext context,
    String message, {
    Color color = Colors.green,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(assetSummaryProvider(classId));
    final assetsAsync = ref.watch(assetListWithStatusProvider(classId));

    // Hàm refresh
    Future<void> refreshData() async {
      await Future.wait([
        ref.refresh(assetSummaryProvider(classId).future),
        ref.refresh(assetListWithStatusProvider(classId).future),
        ref.refresh(assetHistoryProvider(classId).future),
      ]);
    }

    // Bọc RefreshIndicator
    return RefreshIndicator(
      onRefresh: refreshData,
      color: const Color(0xFF2563EB),
      child: SingleChildScrollView(
        // Cho phép cuộn để refresh
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Quản lý tài sản",
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Theo dõi tài sản chung và lịch sử mượn/trả",
              style: GoogleFonts.roboto(
                fontSize: 15,
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await showAddAssetOverlay(
                    context,
                    classId: classId,
                  );

                  if (result == true && context.mounted) {
                    ref.invalidate(assetListWithStatusProvider(classId));
                    ref.invalidate(assetSummaryProvider(classId));

                    _showSnack(context, 'Đã thêm tài sản mới thành công');
                  }
                },
                icon: const Icon(LucideIcons.plus, size: 18),
                label: const Text("Thêm tài sản"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB), // Blue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  SmallStatCard(
                    title: "Tổng tài sản",
                    value: summary['total'].toString(),
                    icon: LucideIcons.box,
                    bgIcon: const Color(0xFFDBEAFE),
                    iconColor: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  SmallStatCard(
                    title: "Có sẵn",
                    value: summary['available'].toString(),
                    icon: LucideIcons.checkCircle,
                    bgIcon: const Color(0xFFDCFCE7),
                    iconColor: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  SmallStatCard(
                    title: "Đang mượn",
                    value: summary['borrowed'].toString(),
                    icon: LucideIcons.user,
                    bgIcon: const Color(0xFFFFEDD5),
                    iconColor: Colors.orange,
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('Lỗi summary: $e'),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.box, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Danh sách tài sản',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  assetsAsync.when(
                    data: (assets) => Column(
                      children: assets.map((item) {
                        return AssetCard(
                          data: item,
                          onViewHistory: () {
                            showAssetHistoryOverlay(
                              context: context,
                              classId: classId,
                              assetId: item.asset.id,
                              assetName: item.asset.name,
                            );
                          },
                          onEdit: () async {
                            final result = await showEditAssetOverlay(
                              context,
                              classId: classId,
                              assetId: item.asset.id,
                              name: item.asset.name,
                              totalQuantity: item.asset.totalQuantity,
                              note: item.asset.note,
                            );

                            if (result == true && context.mounted) {
                              ref.invalidate(
                                assetListWithStatusProvider(classId),
                              );
                              ref.invalidate(assetSummaryProvider(classId));

                              _showSnack(
                                context,
                                'Cập nhật tài sản "${item.asset.name}" thành công',
                              );
                            }
                          },

                          onDelete: () {
                            final isFullyAvailable =
                                item.availableQuantity ==
                                item.asset.totalQuantity;

                            if (!isFullyAvailable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không thể xóa tài sản đang được mượn',
                                  ),
                                ),
                              );
                              return;
                            }

                            showDeleteAssetOverlay(
                              context: context,
                              assetName: item.asset.name,
                              onConfirm: () async {
                                await ref
                                    .read(assetRepositoryProvider)
                                    .deleteAsset(assetId: item.asset.id);

                                ref.invalidate(
                                  assetListWithStatusProvider(classId),
                                );
                                ref.invalidate(assetSummaryProvider(classId));

                                _showSnack(
                                  context,
                                  'Đã xóa tài sản "${item.asset.name}" thành công',
                                );
                              },
                            );
                          },
                        );
                      }).toList(),
                    ),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Lỗi tải assets: $e'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            /// ===== LỊCH SỬ GẦN ĐÂY =====
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TITLE
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 18, color: Colors.grey[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Lịch sử gần đây',
                        style: GoogleFonts.roboto(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// CONTENT
                  Consumer(
                    builder: (context, ref, _) {
                      final historyAsync = ref.watch(
                        assetHistoryProvider(classId),
                      );

                      return historyAsync.when(
                        data: (list) {
                          if (list.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(
                                child: Text(
                                  'Chưa có lịch sử mượn/trả',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            );
                          }

                          // chỉ lấy 5 item gần nhất
                          final recent = list.take(5).toList();

                          return Column(
                            children: recent.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: HistoryItem(history: item),
                              );
                            }).toList(),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Text('Lỗi lịch sử: $e'),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
