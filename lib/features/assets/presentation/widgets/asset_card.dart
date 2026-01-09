import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../data/models/asset_status_model.dart';
import 'package:intl/intl.dart';
class AssetCard extends StatelessWidget {
  final AssetStatusModel data;
  final VoidCallback? onViewHistory;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssetCard({
    super.key,
    required this.data,
    this.onViewHistory,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final asset = data.asset;

    final color = data.isBorrowed ? Colors.orange : Colors.green;
    final bg = data.isBorrowed
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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

                
                Row(
                  children: [
                    Text(
                      'SL: ${asset.totalQuantity}',
                      style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 16),
                  ],
                ),

                const SizedBox(height: 8),

                // Nếu có active loan: show borrower
                if (data.borrowerName != null) ...[
                  Row(
                    children: [
                      Icon(LucideIcons.user, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          data.borrowerName!,
                          style: GoogleFonts.roboto(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                if (data.borrowedAt != null) ...[
                  Row(
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '${DateFormat('HH:mm, dd/MM/yyyy').format(data.borrowedAt!.toLocal())}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 12),

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

  Widget _statusBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        data.statusText,
        style: GoogleFonts.roboto(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

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
