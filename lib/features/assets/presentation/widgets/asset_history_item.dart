import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../data/models/asset_loan_model.dart';

class HistoryItem extends StatelessWidget {
  final AssetLoanModel history;

  const HistoryItem({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    final color = history.isReturned ? Colors.green : Colors.orange;
    final formatter = DateFormat('HH:mm dd/MM/yyyy');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            history.isReturned
                ? Icons.check_circle
                : Icons.access_time,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${history.borrowerName ?? 'Ai đó'} mượn '
                  '${history.quantity} cái',
                  style: GoogleFonts.roboto(fontSize: 13),
                ),
                Text(
                  formatter.format(history.borrowedAt),
                  style: GoogleFonts.roboto(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

