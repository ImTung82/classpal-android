// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../view_models/fund_view_model.dart';
// import '../widgets/transaction_item.dart';
// import '../widgets/personal_status_card.dart';
// import '../widgets/unpaid_list_item.dart';
// import '../../../../core/utils/currency_utils.dart'; // Import tiện ích

// class StudentFundContent extends ConsumerWidget {
//   const StudentFundContent({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final summaryAsync = ref.watch(fundSummaryProvider);
//     final transactionsAsync = ref.watch(fundTransactionsProvider);
//     final campaignAsync = ref.watch(fundCampaignProvider);
//     final unpaidAsync = ref.watch(fundUnpaidProvider);

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text("Quỹ lớp", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
//           Text("Theo dõi thu chi minh bạch", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
//           const SizedBox(height: 16),

//           // 1. Overview Card (Big Green)
//           summaryAsync.when(
//             loading: () => const Center(child: CircularProgressIndicator()),
//             error: (e, s) => const SizedBox(),
//             data: (summary) => Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF00C853), // Green
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Tồn quỹ hiện tại", style: GoogleFonts.roboto(color: Colors.white.withOpacity(0.8), fontSize: 14)),
//                   const SizedBox(height: 4),
//                   // Format tiền ở đây
//                   Text(CurrencyUtils.format(summary.currentBalance), style: GoogleFonts.roboto(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       _buildDetailBox("Tổng thu", CurrencyUtils.format(summary.totalIncome)),
//                       const SizedBox(width: 12),
//                       _buildDetailBox("Tổng chi", CurrencyUtils.format(summary.totalExpense)),
//                     ],
//                   )
//                 ],
//               ),
//             ),
//           ),

//           const SizedBox(height: 24),

//           // 2. Trạng thái nộp tiền của bạn
//           Text("Trạng thái nộp tiền của bạn", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 12),
//           campaignAsync.when(
//             loading: () => const SizedBox(),
//             error: (e, s) => const SizedBox(),
//             data: (campaign) => PersonalStatusCard(campaign: campaign),
//           ),

//           const SizedBox(height: 24),

//           // 3. Chi tiêu gần đây
//           Text("Chi tiêu gần đây", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
//           const SizedBox(height: 12),
//           transactionsAsync.when(
//             loading: () => const SizedBox(),
//             error: (e, s) => const SizedBox(),
//             data: (list) => Column(children: list.map((t) => TransactionItem(transaction: t)).toList()),
//           ),

//           const SizedBox(height: 24),

//           // 4. Danh sách chưa nộp (Minh bạch)
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text("Danh sách chưa nộp", style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 12),
//                 unpaidAsync.when(
//                   loading: () => const SizedBox(),
//                   error: (e, s) => const SizedBox(),
//                   data: (list) => Column(children: list.map((u) => UnpaidListItem(name: u.name)).toList()),
//                 )
//               ],
//             ),
//           ),

//           const SizedBox(height: 80),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailBox(String label, String value) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(label, style: GoogleFonts.roboto(color: Colors.white.withOpacity(0.8), fontSize: 11)),
//             Text(value, style: GoogleFonts.roboto(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
//           ],
//         ),
//       ),
//     );
//   }
// }