import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../data/models/asset_model.dart';

class AssetCard extends StatelessWidget {
  final AssetModel asset;
  final VoidCallback? onViewHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetCard({
    super.key,
    required this.asset,
    this.onViewHistory,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = asset.isBorrowed ? Colors.orange : Colors.green;
    final bg = asset.isBorrowed
        ? const Color(0xFFFFF7ED)
        : const Color(0xFFF0FDF4);

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
          /// ===== NỘI DUNG CHÍNH =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ICON + TÊN + TRẠNG THÁI
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
                        asset.name,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    _statusBadge(color),
                  ],
                ),

                const SizedBox(height: 14),

                /// MÃ + DANH MỤC
                Row(
                  children: [
                    Text(
                      asset.assetCode,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      asset.category,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),


                Row(
                  children: [
                    Icon(LucideIcons.user,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        asset.user,
                        style: GoogleFonts.roboto(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                
                Row( 
                  children: [
                    Icon(LucideIcons.clock,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        asset.time,
                        style: GoogleFonts.roboto(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          /// ===== CỘT HÀNH ĐỘNG =====
          Column(
            children: [
              _actionIcon(
                icon: LucideIcons.clock,
                color: Colors.black,
                onTap: onViewHistory,
              ),
              const SizedBox(height: 12),
              _actionIcon(
                icon: LucideIcons.pencil,
                color: Colors.blue,
                onTap: onEdit,
              ),
              const SizedBox(height: 12),
              _actionIcon(
                icon: LucideIcons.trash2,
                color: Colors.red,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ===== BADGE TRẠNG THÁI =====
  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        asset.isBorrowed ? 'Đang mượn' : 'Có sẵn',
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// ===== ICON HÀNH ĐỘNG =====
  Widget _actionIcon({
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
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
}
