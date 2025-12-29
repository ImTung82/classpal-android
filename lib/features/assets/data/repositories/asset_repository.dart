import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/asset_model.dart';
import '../models/asset_status_model.dart';
import '../models/asset_loan_model.dart';

class AssetRepository {
  final SupabaseClient _db;

  AssetRepository(this._db);

  /// ===============================
  /// LẤY DANH SÁCH TÀI SẢN + TRẠNG THÁI
  ///
  /// - Mỗi asset CHỈ 1 card
  /// - quantity dùng để trừ
  /// - asset_loans chỉ là giao dịch
  /// ===============================
  Future<List<AssetStatusModel>> fetchAssetsWithStatus({
    required String classId,
  }) async {
    final rows = await _db
        .from('assets')
        .select('''
          id,
          class_id,
          name,
          total_quantity,
          condition_status,
          note,
          created_at,
          asset_loans (
            id,
            quantity,
            borrowed_at,
            returned_at,
            borrower_id,
            profiles:borrower_id (
              full_name
            )
          )
        ''')
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    /// ===== MAP ĐỂ GOM ASSET =====
    final Map<String, _AssetAccumulator> map = {};

    for (final r in rows) {
      final asset = AssetModel.fromJson(r);

      // đảm bảo mỗi asset chỉ tạo 1 accumulator
      map.putIfAbsent(asset.id, () => _AssetAccumulator(asset));

      final acc = map[asset.id]!;

      final loans = (r['asset_loans'] as List<dynamic>? ?? []).where(
        (l) => l['returned_at'] == null,
      );

      for (final l in loans) {
        final qty = (l['quantity'] as num?)?.toInt() ?? 1;
        acc.borrowedQuantity += qty;

        final borrowedAtStr = l['borrowed_at'] as String?;
        final borrowedAt = borrowedAtStr == null
            ? null
            : DateTime.parse(borrowedAtStr);

        final borrowerName = (l['profiles'] as Map?)?['full_name'] as String?;

        // lấy người mượn gần nhất
        if (borrowedAt != null &&
            (acc.latestBorrowedAt == null ||
                borrowedAt.isAfter(acc.latestBorrowedAt!))) {
          acc.latestBorrowedAt = borrowedAt;
          acc.latestBorrowerName = borrowerName;
        }
      }
    }

    /// ===== CHUYỂN SANG MODEL HIỂN THỊ =====
    return map.values.map((acc) {
      final available = (acc.asset.totalQuantity - acc.borrowedQuantity).clamp(
        0,
        acc.asset.totalQuantity,
      );

      return AssetStatusModel(
        asset: acc.asset,
        availableQuantity: available,
        borrowerName: acc.latestBorrowerName,
        borrowedAt: acc.latestBorrowedAt,
      );
    }).toList();
  }

  /// ===============================
  /// SUMMARY
  /// ===============================
  Future<Map<String, int>> fetchSummary({required String classId}) async {
    final list = await fetchAssetsWithStatus(classId: classId);

    final total = list.fold(0, (sum, a) => sum + a.asset.totalQuantity);

    final available = list.fold(0, (sum, a) => sum + a.availableQuantity);

    final borrowed = total - available;

    return {'total': total, 'available': available, 'borrowed': borrowed};
  }

  /// ===============================
  /// CRUD ASSETS
  /// ===============================

  Future<void> addAsset({
    required String classId,
    required String name,
    int totalQuantity = 1,
    String conditionStatus = 'good',
    String? note,
  }) async {
    await _db.from('assets').insert({
      'class_id': classId,
      'name': name,
      'total_quantity': totalQuantity,
      'condition_status': conditionStatus,
      'note': note,
    });
  }

  Future<void> updateAsset({
    required String assetId,
    String? name,
    int? totalQuantity,
    String? conditionStatus,
    String? note,
  }) async {
    final payload = <String, dynamic>{};

    if (name != null) payload['name'] = name;
    if (totalQuantity != null) payload['total_quantity'] = totalQuantity;
    if (conditionStatus != null) {
      payload['condition_status'] = conditionStatus;
    }
    if (note != null) payload['note'] = note;

    if (payload.isEmpty) return;

    await _db.from('assets').update(payload).eq('id', assetId);
  }

  Future<void> deleteAsset({required String assetId}) async {
    final res = await _db.from('assets').delete().eq('id', assetId);
  }

  Future<List<AssetLoanModel>> fetchAssetHistory({
    required String classId,
    String? assetId,
  }) async {
    var query = _db.from('asset_loans').select('''
        id,
        class_id,
        asset_id,
        borrower_id,
        quantity,
        borrowed_at,
        returned_at,
        note,
        created_at,
        profiles:borrower_id (
          full_name
        )
      ''');

    // ✅ filter SAU select()
    query = query.eq('class_id', classId);

    if (assetId != null) {
      query = query.eq('asset_id', assetId);
    }

    final rows = await query.order('borrowed_at', ascending: false);

    return rows
        .map<AssetLoanModel>(
          (e) => AssetLoanModel.fromJson(e as Map<String, dynamic>),
        )
        .toList();
  }
}

class _AssetAccumulator {
  final AssetModel asset;
  int borrowedQuantity = 0;
  DateTime? latestBorrowedAt;
  String? latestBorrowerName;

  _AssetAccumulator(this.asset);
}
