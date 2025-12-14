import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fund_models.dart';

final fundRepositoryProvider = Provider<FundRepository>((ref) => MockFundRepository());

abstract class FundRepository {
  Future<FundSummary> fetchSummary();
  Future<List<FundTransaction>> fetchRecentTransactions();
  Future<FundCampaign> fetchActiveCampaign();
  Future<List<UnpaidMember>> fetchUnpaidMembers();
}

class MockFundRepository implements FundRepository {
  @override
  Future<FundSummary> fetchSummary() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return FundSummary(totalIncome: 300000, totalExpense: 125000, currentBalance: 175000);
  }

  @override
  Future<List<FundTransaction>> fetchRecentTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      FundTransaction(id: '1', title: "Tiền photo tài liệu môn Toán", date: "01/12/2024", creator: "Lớp trưởng", amount: 50000, isExpense: true),
      FundTransaction(id: '2', title: "Mua bút lông bảng, giẻ lau", date: "05/12/2024", creator: "Lớp trưởng", amount: 75000, isExpense: true),
    ];
  }

  @override
  Future<FundCampaign> fetchActiveCampaign() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return FundCampaign(
      title: "Quỹ lớp Học kỳ 1", amountPerPerson: 100000, deadline: "15/12/2024",
      paidCount: 35, totalCount: 40, collectedAmount: 3500000
    );
  }

  @override
  Future<List<UnpaidMember>> fetchUnpaidMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      UnpaidMember("Lê Văn C"),
      UnpaidMember("Phạm Thị D"),
      UnpaidMember("Phan Thị M"),
    ];
  }
}