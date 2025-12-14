// 1. Tổng quan quỹ
class FundSummary {
  final int totalIncome; // Tổng thu
  final int totalExpense; // Tổng chi
  final int currentBalance; // Tồn quỹ

  FundSummary({required this.totalIncome, required this.totalExpense, required this.currentBalance});
}

// 2. Giao dịch (Chi tiêu)
class FundTransaction {
  final String id;
  final String title;
  final String date;
  final String creator; // Người tạo (Lớp trưởng)
  final int amount;
  final bool isExpense; // True = Chi (Đỏ), False = Thu (Xanh)

  FundTransaction({
    required this.id, required this.title, required this.date, 
    required this.creator, required this.amount, this.isExpense = true
  });
}

// 3. Chiến dịch thu quỹ (Ví dụ: Quỹ HK1)
class FundCampaign {
  final String title;
  final int amountPerPerson;
  final String deadline;
  final int paidCount;
  final int totalCount;
  final int collectedAmount; // Số tiền đã thu được

  FundCampaign({
    required this.title, required this.amountPerPerson, required this.deadline,
    required this.paidCount, required this.totalCount, required this.collectedAmount
  });
}

// 4. Người chưa nộp (Cho danh sách minh bạch)
class UnpaidMember {
  final String name;
  UnpaidMember(this.name);
}