/// ===============================
/// FUND MODELS (OWNER)
/// Mapping theo Supabase schema
/// ===============================

/// 1. Tổng quan quỹ (Derived – không phải table)
class FundSummary {
  final int totalIncome;   // SUM(amount) WHERE is_expense = false
  final int totalExpense;  // SUM(amount) WHERE is_expense = true
  final int balance;       // totalIncome - totalExpense

  const FundSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });
}

/// 2. Chiến dịch thu quỹ
/// Table: fund_campaigns
class FundCampaign {
  final String id;
  final String classId;
  final String title;
  final String? description;
  final int amountPerPerson;
  final DateTime? deadline;
  final bool isClosed;
  final DateTime createdAt;

  /// Owner-only (computed)
  final int paidCount;
  final int totalMemberCount;
  final int collectedAmount;

  const FundCampaign({
    required this.id,
    required this.classId,
    required this.title,
    this.description,
    required this.amountPerPerson,
    this.deadline,
    required this.isClosed,
    required this.createdAt,
    required this.paidCount,
    required this.totalMemberCount,
    required this.collectedAmount,
  });

  factory FundCampaign.fromMap(
    Map<String, dynamic> map, {
    required int paidCount,
    required int totalMemberCount,
    required int collectedAmount,
  }) {
    return FundCampaign(
      id: map['id'],
      classId: map['class_id'],
      title: map['title'],
      description: map['description'],
      amountPerPerson: map['amount_per_person'],
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'])
          : null,
      isClosed: map['is_closed'],
      createdAt: DateTime.parse(map['created_at']),
      paidCount: paidCount,
      totalMemberCount: totalMemberCount,
      collectedAmount: collectedAmount,
    );
  }
}

/// 3. Giao dịch quỹ
/// Table: fund_transactions
class FundTransaction {
  final String id;
  final String classId;
  final String? campaignId;
  final String title;
  final int amount;
  final bool isExpense;
  final String? payerId;
  final String? payerName; // JOIN profiles
  final String? evidenceUrl;
  final DateTime createdAt;

  const FundTransaction({
    required this.id,
    required this.classId,
    this.campaignId,
    required this.title,
    required this.amount,
    required this.isExpense,
    this.payerId,
    this.payerName,
    this.evidenceUrl,
    required this.createdAt,
  });

  factory FundTransaction.fromMap(Map<String, dynamic> map) {
    return FundTransaction(
      id: map['id'],
      classId: map['class_id'],
      campaignId: map['campaign_id'],
      title: map['title'],
      amount: map['amount'],
      isExpense: map['is_expense'],
      payerId: map['payer_id'],
      payerName: map['profiles']?['full_name'],
      evidenceUrl: map['evidence_url'],
      createdAt: DateTime.parse(map['created_at']).toLocal(),
    );
  }
}

/// 4. Thành viên chưa nộp (Derived – owner only)
class UnpaidMember {
  final String userId;
  final String fullName;
  final String studentCode;
  final bool isPaid;
  const UnpaidMember({
    required this.userId,
    required this.fullName,
    required this.studentCode,
    required this.isPaid,
  });
}
