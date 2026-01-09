import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/asset_status_model.dart';
import '../view_models/asset_view_model.dart';

class AvailableAssetItem extends ConsumerStatefulWidget {
  final String classId;
  final AssetStatusModel data;

  const AvailableAssetItem({
    super.key,
    required this.classId,
    required this.data,
  });

  @override
  ConsumerState<AvailableAssetItem> createState() => _AvailableAssetItemState();
}

class _AvailableAssetItemState extends ConsumerState<AvailableAssetItem> {
  bool _loading = false;

  Future<void> _borrow() async {
    if (_loading) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập')),
      );
      return;
    }

    if (widget.data.availableQuantity <= 0) return;

    setState(() => _loading = true);
    try {
      await ref.read(assetRepositoryProvider).borrowAsset(
            classId: widget.classId,
            assetId: widget.data.asset.id,
            borrowerId: userId,
            quantity: 1,
          );

      ref.invalidate(assetListWithStatusProvider(widget.classId));
      ref.invalidate(assetSummaryProvider(widget.classId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi mượn tài sản: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.data.asset;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _icon(),
          const SizedBox(width: 12),
          Expanded(child: _info(asset.name, asset.id)),
          _borrowButton(),
        ],
      ),
    );
  }

  Widget _icon() => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(LucideIcons.box, color: Colors.green, size: 20),
      );

  Widget _info(String name, String _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
          ),
          Text(
            'Còn: ${widget.data.availableQuantity}/${widget.data.asset.totalQuantity}',
            style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
          ),
        ],
      );

  Widget _borrowButton() => ElevatedButton(
        onPressed: (widget.data.availableQuantity <= 0 || _loading) ? null : _borrow,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
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
            : const Text('Mượn'),
      );
}
