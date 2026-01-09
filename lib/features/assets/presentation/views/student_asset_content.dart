import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/asset_view_model.dart';
import '../widgets/stat_card.dart';
import '../widgets/asset_section.dart';
import '../../data/models/asset_status_model.dart';

class StudentAssetContent extends ConsumerWidget {
  final String classId;

  const StudentAssetContent({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assetsAsync = ref.watch(assetListWithStatusProvider(classId));
    final summaryAsync = ref.watch(assetSummaryProvider(classId));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ===== HEADER =====
              Text(
                'Tài sản lớp',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Mượn và trả tài sản chung',
                style: GoogleFonts.roboto(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 16),

              /// ===== STATS =====
              summaryAsync.when(
                data: (summary) => Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Có sẵn',
                        value: '${summary['available']}',
                        type: StatType.available,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Đang mượn',
                        value: '${summary['borrowed']}',
                        type: StatType.borrowed,
                      ),
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Lỗi thống kê: $e'),
              ),

              const SizedBox(height: 20),

              /// ===== ASSETS =====
              assetsAsync.when(
                data: (List<AssetStatusModel> assets) {
                  /// ✅ CÓ SẴN = còn quantity
                  final availableAssets = assets
                      .where((a) => a.availableQuantity > 0)
                      .toList();

                  /// ✅ ĐANG HẾT = available = 0
                  final borrowedAssets = assets
                      .where((a) => a.isBorrowed)
                      .toList();

                  return Column(
                    children: [
                      /// ===== AVAILABLE =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: AssetSection.available(
                          classId: classId,
                          title: 'Tài sản có sẵn',
                          assets: availableAssets,
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// ===== BORROWED =====
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: AssetSection.borrowed(
                          classId: classId,
                          title: 'Tài sản đang được mượn',
                          assets: borrowedAssets,
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Text('Lỗi tải tài sản: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
