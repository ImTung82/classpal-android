import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view_models/asset_providers.dart';
import '../widgets/stat_card.dart';
import '../widgets/asset_section.dart';

class StudentAssetContent extends ConsumerWidget {
  const StudentAssetContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(assetSummaryProvider);
    final assets = ref.watch(assetListProvider);

    final availableAssets =
        assets.where((a) => !a.isBorrowed).toList();
    final borrowedAssets =
        assets.where((a) => a.isBorrowed).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
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
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 16),

              /// STATS
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Có sẵn',
                      value: '${summary['available']} tài sản',
                      type: StatType.available,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      title: 'Đang mượn',
                      value: '${summary['borrowed']} tài sản',
                      type: StatType.borrowed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// AVAILABLE
              AssetSection.available(
                title: 'Tài sản có sẵn',
                assets: availableAssets,
              ),

              const SizedBox(height: 20),

              /// BORROWED
              AssetSection.borrowed(
                title: 'Tài sản đang được mượn',
                assets: borrowedAssets,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
