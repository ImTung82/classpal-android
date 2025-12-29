import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/asset_repository.dart';
import '../../data/models/asset_status_model.dart';
import '../../data/models/asset_loan_model.dart';
/// Provider SupabaseClient
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository(ref.read(supabaseClientProvider));
});

/// Bạn sẽ truyền classId từ màn hình (owner/student)
final assetListWithStatusProvider =
    FutureProvider.family<List<AssetStatusModel>, String>((ref, classId) async {
  return ref.read(assetRepositoryProvider).fetchAssetsWithStatus(classId: classId);
});

final assetSummaryProvider =
    FutureProvider.family<Map<String, int>, String>((ref, classId) async {
  return ref.read(assetRepositoryProvider).fetchSummary(classId: classId);
});

final assetHistoryProvider = FutureProvider.family<
    List<AssetLoanModel>,
    String>((ref, classId) async {
  final repo = ref.read(assetRepositoryProvider);
  return repo.fetchAssetHistory(classId: classId);
});

final assetHistoryByAssetProvider = FutureProvider.family<
    List<AssetLoanModel>,
    ({String classId, String assetId})>((ref, params) async {
  final repo = ref.read(assetRepositoryProvider);
  return repo.fetchAssetHistory(
    classId: params.classId,
    assetId: params.assetId,
  );
});
