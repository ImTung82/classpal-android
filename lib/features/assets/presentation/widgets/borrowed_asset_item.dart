import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/asset_status_model.dart';
import '../view_models/asset_view_model.dart';
import 'package:intl/intl.dart';
class BorrowedAssetItem extends ConsumerStatefulWidget {
  final String classId;
  final AssetStatusModel data;

  const BorrowedAssetItem({
    super.key,
    required this.classId,
    required this.data,
  });

  @override
  ConsumerState<BorrowedAssetItem> createState() => _BorrowedAssetItemState();
}

class _BorrowedAssetItemState extends ConsumerState<BorrowedAssetItem> {
  bool _loading = false;

  Future<void> _returnAsset() async {
    if (_loading) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final loanId = await ref.read(assetRepositoryProvider).fetchMyLatestActiveLoanId(
            assetId: widget.data.asset.id,
            borrowerId: userId,
          );

      if (loanId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bạn không có lượt mượn nào đang hoạt động cho tài sản này'),
          ),
        );
        return;
      }

      await ref.read(assetRepositoryProvider).returnAsset(loanId: loanId);

      ref.invalidate(assetListWithStatusProvider(widget.classId));
      ref.invalidate(assetSummaryProvider(widget.classId));
      ref.invalidate(assetHistoryProvider(widget.classId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi trả tài sản: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
Widget build(BuildContext context) {
  final asset = widget.data.asset;
  final borrowedCount =
      asset.totalQuantity - widget.data.availableQuantity;

  final currentUserId =
      Supabase.instance.client.auth.currentUser?.id;

  final isMine =
      currentUserId != null &&
      widget.data.borrowerId == currentUserId;

  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFFCC99)),
    ),
    child: Row(
      children: [
        _icon(),
        const SizedBox(width: 12),

        /// ===== INFO =====
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// TÊN TÀI SẢN
              Text(
                asset.name,
                style: GoogleFonts.roboto(
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 4),

              if (widget.data.borrowerName != null &&
                  widget.data.borrowedAt != null)
                Text(
                  '${widget.data.borrowerName} · '
                  '${DateFormat('HH:mm, dd/MM/yyyy').format(widget.data.borrowedAt!.toLocal())}',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: Colors.grey[700],
                  ),
                ),

              const SizedBox(height: 2),

              /// SỐ LƯỢNG
              Text(
                'Đang mượn: $borrowedCount/${asset.totalQuantity}',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        /// ===== NÚT TRẢ (CHỈ HIỆN KHI LÀ MÌNH) =====
        if (isMine) _returnButton(),
      ],
    ),
  );
}


  Widget _icon() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEDD5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.user, color: Colors.orange, size: 18),
      );

  Widget _returnButton() => ElevatedButton(
        onPressed: _loading ? null : _returnAsset,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Trả'),
      );
}
