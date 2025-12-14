import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

final assetSummaryProvider = Provider((ref) {
  return {'total': 4, 'available': 2, 'borrowed': 2};
});

final assetListProvider = Provider((ref) {
  return [
    {
      'name': 'Remote Điều hòa',
      'assetCode': '#001',
      'category': 'Điện tử',
      'status': 'borrowed',
      'user': 'Nguyễn Văn A',
      'time': '09:00, 06/12/2024',
    },
    {
      'name': 'Chìa khóa tủ Bảng',
      'assetCode': '#002',
      'category': 'Văn phòng phẩm',
      'status': 'available',
      'user': 'Nguyễn Văn A',
      'time': '09:00, 06/12/2024',
    },
  ];
});

final assetHistoryProvider = Provider((ref) {
  return [
    {
      'text': 'Nguyễn Văn A mượn Remote Điều hòa',
      'time': '09:00, 06/12/2024',
      'type': 'borrow',
    },
    {
      'text': 'Lê Văn C trả Remote Máy chiếu',
      'time': '16:00, 04/12/2024',
      'type': 'return',
    },
  ];
});

/// ====== SCREEN ======
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
          /// HEADER
          Text(
            "Quản lý tài sản",
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Theo dõi tài sản chung và lịch sử mượn/trả",
            style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),

          /// BUTTON
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(LucideIcons.plus, size: 16),
            label: const Text("Thêm tài sản"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              minimumSize: const Size(0, 36),
            ),
          ),

          const SizedBox(height: 16),

          /// STATS
          _smallStatCard(
            "Tổng tài sản",
            summary['total'].toString(),
            LucideIcons.box,
            const Color(0xFFDBEAFE),
            Colors.blue,
          ),
          const SizedBox(height: 12),
          _smallStatCard(
            "Có sẵn",
            summary['available'].toString(),
            LucideIcons.checkCircle,
            const Color(0xFFDCFCE7),
            Colors.green,
          ),
          const SizedBox(height: 12),
          _smallStatCard(
            "Đang mượn",
            summary['borrowed'].toString(),
            LucideIcons.user,
            const Color(0xFFFFEDD5),
            Colors.orange,
          ),

          const SizedBox(height: 24),

          /// ASSET LIST
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
                const SizedBox(height: 18),

                /// ===== DANH SÁCH =====
                Column(
                  children: assets.map((a) {
                    final isBorrowed = a['status'] == 'borrowed';
                    return _assetCard(
                      name: (a['name'] ?? '').toString(),
                      assetCode: (a['assetCode'] ?? '').toString(),
                      category: (a['category'] ?? '').toString(),
                      user: (a['user'] ?? '').toString(),
                      time: (a['time'] ?? '').toString(),
                      isBorrowed: isBorrowed,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// HISTORY
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

                const SizedBox(height: 24),

                /// ===== DANH SÁCH LỊCH SỬ =====
                Column(
                  children: history.map((h) {
                    final isReturn = h['type'] == 'return';
                    return _historyItem(
                      text: (h['text'] ?? '').toString(),
                      time: (h['time'] ?? '').toString(),
                      isReturn: isReturn,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 60),
        ],
      ),
    );
  }

  /// ====== WIDGETS ======

  Widget _smallStatCard(
    String title,
    String value,
    IconData icon,
    Color bgIcon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgIcon,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _assetCard({
    required String name,
    required String assetCode,
    required String category,
    required String user,
    required String time,
    required bool isBorrowed,
  }) {
    final color = isBorrowed ? Colors.orange : Colors.green;
    final bg = isBorrowed ? const Color(0xFFFFF7ED) : const Color(0xFFF0FDF4);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ==== NỘI DUNG CHÍNH ====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== HÀNG TRÊN: ICON + TÊN + TRẠNG THÁI =====
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(LucideIcons.box, color: color, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isBorrowed ? 'Đang mượn' : 'Có sẵn',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// ===== MÃ + DANH MỤC (THẲNG HÀNG) =====
                Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(
                      assetCode,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                /// ===== USER + TIME =====
                Row(
                  children: [
                    Icon(LucideIcons.user, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(user, style: GoogleFonts.roboto(fontSize: 12)),
                    const SizedBox(width: 16),
                    Icon(LucideIcons.clock, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(time, style: GoogleFonts.roboto(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// ==== CỘT HÀNH ĐỘNG ====
          Column(
            children: [
              _actionIcon(
                icon: LucideIcons.clock,
                color: Colors.black,
                onTap: () {
                  // xem lịch sử mượn
                },
              ),
              const SizedBox(height: 12),
              _actionIcon(
                icon: LucideIcons.pencil,
                color: Colors.blue,
                onTap: () {
                  // sửa tài sản
                },
              ),
              const SizedBox(height: 12),
              _actionIcon(
                icon: LucideIcons.trash2,
                color: Colors.red,
                onTap: () {
                  // xóa tài sản
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Widget _historyItem({
    required String text,
    required String time,
    required bool isReturn,
  }) {
    final color = isReturn ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            isReturn ? LucideIcons.checkCircle : LucideIcons.alertCircle,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(text, style: GoogleFonts.roboto(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GoogleFonts.roboto(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
