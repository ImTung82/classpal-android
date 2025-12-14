import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../view_models/asset_providers.dart';
import '../widgets/asset_card.dart';
import '../widgets/asset_history_item.dart';
import '../widgets/small_stat_card.dart';
import '../widgets/add_asset.dart';
import '../widgets/edit_asset.dart';

class OwnerAssetContent extends ConsumerWidget {
  const OwnerAssetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(assetSummaryProvider);
    final assets = ref.watch(assetListProvider);
    final history = ref.watch(assetHistoryProvider);

    return SingleChildScrollView(
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
              onPressed: () {
                showAddAssetOverlay(context);
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
                /// ===== TIÊU ĐỀ (NẰM TRONG KHỐI) =====
                Row(
                  children: [
                    Icon(LucideIcons.box, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Danh sách tài sản",
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ===== DANH SÁCH TÀI SẢN =====
                Column(
                  children: assets.map((asset) {
                    return AssetCard(
                      asset: asset,
                      onViewHistory: () {},
                      onEdit: () {
                        showEditAssetOverlay(
                          context,
                          name: asset.name,
                          category: asset.category,
                        );
                      },
                      onDelete: () {},
                    );
                  }).toList(),
                ),
              ],
            ),
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
                /// ===== TIÊU ĐỀ =====
                Row(
                  children: [
                    Icon(LucideIcons.clock, size: 18, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Text(
                      "Lịch sử gần đây",
                      style: GoogleFonts.roboto(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                /// ===== DANH SÁCH LỊCH SỬ =====
                Column(
                  children: history.map((item) {
                    return HistoryItem(history: item);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
