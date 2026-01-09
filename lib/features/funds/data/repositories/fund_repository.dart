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
  Future<List<FundCampaign>> fetchCampaigns(String classId);
  Future<List<UnpaidMember>> fetchUnpaidMembers({
    required String classId,
    required String campaignId,
  });
  Future<void> addExpense({
    required String classId,
    required String title,
    required int amount,
    DateTime? spentAt,
    String? evidenceUrl,
  });
  Future<List<FundTransaction>> fetchExpenses(String classId);
  Future<void> confirmPaid({
    required String classId,
    required String campaignId,
    required String userId,
    required String payerName,
    required int amount,
  });
  Future<List<FundCampaignHistory>> fetchCampaignHistory(String classId);
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
  Future<void> createCampaign({
    required String classId,
    required String title,
    required int amountPerPerson,
    DateTime? deadline,
  }) async {
    await supabase.from('fund_campaigns').insert({
      'class_id': classId,
      'title': title,
      'amount_per_person': amountPerPerson,
      'deadline': deadline == null
          ? null
          : "${deadline.year}-"
                "${deadline.month.toString().padLeft(2, '0')}-"
                "${deadline.day.toString().padLeft(2, '0')}",
      'is_closed': false,
    });
  }

  @override
  Future<List<FundCampaign>> fetchCampaigns(String classId) async {
    final campaigns = await supabase
        .from('fund_campaigns')
        .select()
        .eq('class_id', classId)
        .eq('is_closed', false)
        .order('created_at', ascending: false);

    final members = await supabase
        .from('class_members')
        .select('id')
        .eq('class_id', classId);

    final totalMemberCount = members.length;

    List<FundCampaign> result = [];

    for (final campaign in campaigns) {
      final campaignId = campaign['id'];

      final paid = await supabase
          .from('fund_transactions')
          .select('payer_id, amount')
          .eq('campaign_id', campaignId)
          .eq('is_expense', false);

      final paidUserIds = paid.map((e) => e['payer_id'] as String).toSet();

      final collectedAmount = paid.fold<int>(
        0,
        (sum, e) => sum + (e['amount'] as int),
      );

      result.add(
        FundCampaign.fromMap(
          campaign,
          paidCount: paidUserIds.length,
          totalMemberCount: totalMemberCount,
          collectedAmount: collectedAmount,
        ),
      );
    }

    return result;
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
        .order('created_at', ascending: false)
        .limit(8);
    return res.map<FundTransaction>((row) {
      return FundTransaction.fromMap(row);
    }).toList();
  }

  @override
  Future<List<UnpaidMember>> fetchUnpaidMembers({
    required String classId,
    required String campaignId,
  }) async {
    final members = await supabase
        .from('class_members')
        .select('user_id, student_code, profiles(full_name)')
        .eq('class_id', classId);

    final paid = await supabase
        .from('fund_transactions')
        .select('payer_id')
        .eq('campaign_id', campaignId)
        .eq('is_expense', false);

    final paidUserIds = paid.map((e) => e['payer_id'] as String).toSet();

    return members.map<UnpaidMember>((m) {
      final userId = m['user_id'] as String;

      return UnpaidMember(
        userId: userId,
        fullName: m['profiles']?['full_name'] ?? 'Chưa có tên',
        studentCode: (m['student_code'] ?? '').toString(),
        isPaid: paidUserIds.contains(userId),
      );
    }).toList();
  }

  @override
  Future<void> confirmPaid({
    required String classId,
    required String campaignId,
    required String userId,
    required String payerName,
    required int amount,
  }) async {
    // 1. Ghi nhận nộp tiền
    await supabase.from('fund_transactions').insert({
      'class_id': classId,
      'campaign_id': campaignId,
      'title': 'Nộp quỹ',
      'amount': amount,
      'is_expense': false,
      'payer_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 2. Check đã đủ người chưa
    final members = await supabase
        .from('class_members')
        .select('id')
        .eq('class_id', classId);

    final paid = await supabase
        .from('fund_transactions')
        .select('payer_id')
        .eq('campaign_id', campaignId)
        .eq('is_expense', false);

    if (paid.length >= members.length) {
      await supabase
          .from('fund_campaigns')
          .update({'is_closed': true})
          .eq('id', campaignId);
    }
  }

  @override
  Future<List<FundCampaignHistory>> fetchCampaignHistory(String classId) async {
    final userId = supabase.auth.currentUser!.id;

    // 1. Lấy tất cả campaign (cả mở + đóng)
    final campaigns = await supabase
        .from('fund_campaigns')
        .select()
        .eq('class_id', classId)
        .order('created_at', ascending: false);

    // 2. Tổng số thành viên lớp
    final members = await supabase
        .from('class_members')
        .select('id')
        .eq('class_id', classId)
        .eq('is_active', true);

    final totalMembers = members.length;

    final List<FundCampaignHistory> result = [];

    for (final c in campaigns) {
      final campaignId = c['id'];

      // 3. Các khoản đã nộp
      final paid = await supabase
          .from('fund_transactions')
          .select('payer_id')
          .eq('campaign_id', campaignId)
          .eq('is_expense', false);

      final paidUserIds = paid.map((e) => e['payer_id'] as String).toSet();

      // 4. Campaign model
      final campaign = FundCampaign.fromMap(
        c,
        paidCount: paidUserIds.length,
        totalMemberCount: totalMembers,
        collectedAmount: paidUserIds.length * (c['amount_per_person'] as int),
      );

      result.add(
        FundCampaignHistory(
          campaign: campaign,
          totalMembers: totalMembers,
          paidMembers: paidUserIds.length,
          isPaidByMe: paidUserIds.contains(userId),
        ),
      );
    }

    return result;
  }
}
