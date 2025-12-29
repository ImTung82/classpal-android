import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/asset_repository.dart';

final assetRepositoryProvider = Provider((ref) {
  return AssetRepository();
});

final assetSummaryProvider = Provider((ref) {
  return ref.read(assetRepositoryProvider).getSummary();
});

final assetListProvider = Provider((ref) {
  return ref.read(assetRepositoryProvider).getAssets();
});

final assetHistoryProvider = Provider((ref) {
  return ref.read(assetRepositoryProvider).getHistory();
});
