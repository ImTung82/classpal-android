import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showDeleteAssetOverlay({
  required BuildContext context,
  required String assetName,
  required Future<void> Function() onConfirm, // 🔥 CHANGED
}) {
  showGeneralDialog(
    context: context,
    barrierLabel: 'DeleteAsset',
    barrierDismissible: false,
    barrierColor: Colors.black54,
    transitionDuration: Duration.zero,
    pageBuilder: (_, __, ___) {
      return DeleteAssetOverlay(
        assetName: assetName,
        onConfirm: onConfirm,
      );
    },
  );
}

class DeleteAssetOverlay extends StatefulWidget {
  final String assetName;
  final Future<void> Function() onConfirm;

  const DeleteAssetOverlay({
    super.key,
    required this.assetName,
    required this.onConfirm,
  });

  @override
  State<DeleteAssetOverlay> createState() => _DeleteAssetOverlayState();
}

class _DeleteAssetOverlayState extends State<DeleteAssetOverlay> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    if (_isDeleting) return;

    setState(() => _isDeleting = true);

    try {
      await widget.onConfirm();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

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
              Text(
                'Xóa tài sản',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(text: 'Bạn có chắc chắn muốn xóa tài sản '),
                    TextSpan(
                      text: widget.assetName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const TextSpan(
                      text: '? Hành động này không thể hoàn tác.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextButton(
                        onPressed:
                            _isDeleting ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: const Color(0xFFF5F5F5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hủy',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isDeleting ? null : _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isDeleting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Xóa tài sản',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
