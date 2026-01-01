import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/fund_models.dart';
import '../../data/repositories/fund_repository.dart';

final fundSummaryProvider = FutureProvider.family<FundSummary, String>((
  ref,
  classId,
) async {
  return ref.watch(fundRepositoryProvider).fetchSummary(classId);
});

final fundActionProvider = Provider((ref) {
  return _FundAction(ref);
});

class _FundAction {
  final Ref ref;
  _FundAction(this.ref);

  Future<void> createCampaign({
    required String classId,
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  }) async {
    await ref
        .read(fundRepositoryProvider)
        .createCampaign(
          classId: classId,
          title: title,
          amountPerPerson: amountPerPerson,
          deadline: deadline,
        );

    // refresh UI
    ref.invalidate(fundSummaryProvider(classId));
    ref.invalidate(fundCampaignProvider(classId)); // làm sau
  }

  Future<void> addExpense({
    required String classId,
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  }) async {
    await ref
        .read(fundRepositoryProvider)
        .addExpense(
          classId: classId,
          title: title,
          amount: amount,
          spentAt: spentAt,
          evidenceUrl: evidenceUrl,
        );

    // 🔥 REFRESH UI NGAY
    ref.invalidate(fundSummaryProvider(classId));
    ref.invalidate(fundTransactionsProvider(classId));
  }
}

final fundCampaignProvider = FutureProvider.family<FundCampaign?, String>((
  ref,
  classId,
) async {
  return ref.watch(fundRepositoryProvider).fetchActiveCampaign(classId);
});

final fundTransactionsProvider =
    FutureProvider.family<List<FundTransaction>, String>((ref, classId) async {
      return ref.watch(fundRepositoryProvider).fetchExpenses(classId);
    });
