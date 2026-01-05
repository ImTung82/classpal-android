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


    ref.invalidate(fundSummaryProvider(classId));
    ref.invalidate(fundCampaignsProvider(classId)); 
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

    ref.invalidate(fundSummaryProvider(classId));
    ref.invalidate(fundTransactionsProvider(classId));
  }

  Future<void> confirmPaid({
    required String classId,
    required FundCampaign campaign,
    required UnpaidMember member,
  }) async {
    await ref
        .read(fundRepositoryProvider)
        .confirmPaid(
          classId: classId,
          campaignId: campaign.id,
          userId: member.userId,
          payerName: member.fullName,
          amount: campaign.amountPerPerson,
        );

    ref.invalidate(fundCampaignsProvider(classId));
    ref.invalidate(
      fundUnpaidProvider((classId: classId, campaignId: campaign.id)),
    );
    ref.invalidate(fundSummaryProvider(classId));
  }
}

final fundCampaignsProvider = FutureProvider.family<List<FundCampaign>, String>(
  (ref, classId) async {
    return ref.watch(fundRepositoryProvider).fetchCampaigns(classId);
  },
);

final fundTransactionsProvider =
    FutureProvider.family<List<FundTransaction>, String>((ref, classId) async {
      return ref.watch(fundRepositoryProvider).fetchExpenses(classId);
    });

typedef UnpaidArgs = ({String classId, String campaignId});

final fundUnpaidProvider =
    FutureProvider.family<List<UnpaidMember>, UnpaidArgs>((ref, args) async {
      return ref
          .watch(fundRepositoryProvider)
          .fetchUnpaidMembers(
            classId: args.classId,
            campaignId: args.campaignId,
          );
    });
