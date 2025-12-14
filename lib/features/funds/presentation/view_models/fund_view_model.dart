import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fund_models.dart';
import '../../data/repositories/fund_repository.dart';

final fundSummaryProvider = FutureProvider<FundSummary>((ref) async {
  return ref.watch(fundRepositoryProvider).fetchSummary();
});

final fundTransactionsProvider = FutureProvider<List<FundTransaction>>((ref) async {
  return ref.watch(fundRepositoryProvider).fetchRecentTransactions();
});

final fundCampaignProvider = FutureProvider<FundCampaign>((ref) async {
  return ref.watch(fundRepositoryProvider).fetchActiveCampaign();
});

final fundUnpaidProvider = FutureProvider<List<UnpaidMember>>((ref) async {
  return ref.watch(fundRepositoryProvider).fetchUnpaidMembers();
});