import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fund_models.dart';

final fundRepositoryProvider = Provider<FundRepository>((ref) {
  return FundRepositoryImpl(Supabase.instance.client);
});

abstract class FundRepository {
  Future<FundSummary> fetchSummary(String classId);
  Future<void> createCampaign({
    required String classId,
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  });
  Future<FundCampaign?> fetchActiveCampaign(String classId);
  Future<void> closeAllActiveCampaigns(String classId);
  Future<void> addExpense({
    required String classId,
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  });
  Future<List<FundTransaction>> fetchExpenses(String classId);
}

class FundRepositoryImpl implements FundRepository {
  final SupabaseClient supabase;
  FundRepositoryImpl(this.supabase);

  @override
  Future<FundSummary> fetchSummary(String classId) async {
    final res = await supabase
        .from('fund_transactions')
        .select('amount, is_expense')
        .eq('class_id', classId);

    int totalIncome = 0;
    int totalExpense = 0;

    for (final row in res) {
      final amount = row['amount'] as int;
      final isExpense = row['is_expense'] as bool;

      if (isExpense) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }
    }

    return FundSummary(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      balance: totalIncome - totalExpense,
    );
  }

  @override
  Future<void> closeAllActiveCampaigns(String classId) async {
    await supabase
        .from('fund_campaigns')
        .update({'is_closed': true})
        .eq('class_id', classId)
        .eq('is_closed', false);
  }

  @override
  Future<void> createCampaign({
    required String classId,
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  }) async {
    await closeAllActiveCampaigns(classId);
    await supabase.from('fund_campaigns').insert({
      'class_id': classId,
      'title': title,
      'amount_per_person': amountPerPerson,
      'deadline': deadline == null
          ? null
          : "${deadline.year}-"
                "${deadline.month.toString().padLeft(2, '0')}-"
                "${deadline.day.toString().padLeft(2, '0')}",
    });
  }

  @override
  Future<FundCampaign?> fetchActiveCampaign(String classId) async {
    // 1. Campaign đang mở
    final campaigns = await supabase
        .from('fund_campaigns')
        .select()
        .eq('class_id', classId)
        .eq('is_closed', false)
        .order('created_at', ascending: false)
        .limit(1);

    if (campaigns.isEmpty) return null;

    final campaign = campaigns.first;

    final campaignId = campaign['id'];

    // 2. Tổng số thành viên lớp
    final totalMembers = await supabase
        .from('class_members')
        .select('id')
        .eq('class_id', classId);

    // 3. Những người đã nộp
    final paidMembers = await supabase
        .from('fund_transactions')
        .select('payer_id')
        .eq('campaign_id', campaignId)
        .eq('is_expense', false);

    // 4. Tổng tiền đã thu
    final collected = await supabase
        .from('fund_transactions')
        .select('amount')
        .eq('campaign_id', campaignId)
        .eq('is_expense', false);

    final collectedAmount = collected.fold<int>(
      0,
      (sum, row) => sum + (row['amount'] as int),
    );

    return FundCampaign.fromMap(
      campaign,
      paidCount: paidMembers.length,
      totalMemberCount: totalMembers.length,
      collectedAmount: collectedAmount,
    );
  }

  @override
  Future<void> addExpense({
    required String classId,
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  }) async {
    final DateTime createdAt = spentAt == null
        ? DateTime.now()
        : DateTime(spentAt.year, spentAt.month, spentAt.day, 12);

    await supabase.from('fund_transactions').insert({
      'class_id': classId,
      'title': title,
      'amount': amount,
      'is_expense': true,
      'created_at': createdAt.toIso8601String(),
      'evidence_url': evidenceUrl,
    });
  }

  @override
  Future<List<FundTransaction>> fetchExpenses(String classId) async {
    final res = await supabase
        .from('fund_transactions')
        .select()
        .eq('class_id', classId)
        .eq('is_expense', true)
        .order('created_at', ascending: false);

    return res.map<FundTransaction>((row) {
      return FundTransaction.fromMap(row);
    }).toList();
  }
}
