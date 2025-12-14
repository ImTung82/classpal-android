import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/dashboard_models.dart';

class EventCardItem extends StatelessWidget {
  final EventData data;
  const EventCardItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    double progress = data.total == 0 ? 0 : data.current / data.total;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text(data.date, style: GoogleFonts.roboto(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                  child: Text("Đang mở", style: GoogleFonts.roboto(color: Colors.green[800], fontSize: 11, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A84F8)), minHeight: 6),
          ),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerRight, child: Text("${data.current}/${data.total}", style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600])))
        ],
      ),
    );
  }
}