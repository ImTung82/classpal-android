import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showAssetHistoryOverlay({
  required BuildContext context,
  required String assetName,
  required String borrowerName,
  required String time,
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'AssetHistory',
    barrierDismissible: true,
    barrierColor: Colors.black54,
    transitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) {
      return AssetHistoryOverlay(
        assetName: assetName,
        borrowerName: borrowerName,
        time: time,
      );
    },
  );
}

class AssetHistoryOverlay extends StatelessWidget {
  final String assetName;
  final String borrowerName;
  final String time;

  const AssetHistoryOverlay({
    super.key,
    required this.assetName,
    required this.borrowerName,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
              /// ===== TITLE =====
              Text(
                'Lịch sử: $assetName',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// ===== HISTORY ITEM =====
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// icon !
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF97316),
                          width: 2,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          '!',
                          style: TextStyle(
                            color: Color(0xFFF97316),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// content
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$borrowerName mượn',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              /// ===== CLOSE BUTTON =====
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
                  child: const Text('Đóng', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}