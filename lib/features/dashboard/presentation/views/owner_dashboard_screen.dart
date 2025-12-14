import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

// 1. Import Core Widgets
import '../../../../core/widgets/app_header.dart'; 
import '../../../../core/widgets/app_bottom_nav.dart';

// 2. Import Data Models & ViewModels (Quan trọng)
import '../../data/models/dashboard_models.dart';
import '../view_models/dashboard_view_model.dart'; 

// 3. Import Local Widgets
import '../widgets/stat_card.dart';
import '../widgets/duty_list_item.dart';
import '../widgets/event_card_item.dart';
import '../widgets/unpaid_student_item.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _bottomNavIndex = 0; 

  @override
  Widget build(BuildContext context) {
    // ---------------------------------------------------------
    // TUÂN THỦ MVVM + RIVERPOD:
    // Không gọi Repo trực tiếp. Lắng nghe dữ liệu từ ViewModel.
    // ---------------------------------------------------------
    final statsAsync = ref.watch(statsProvider);
    final dutiesAsync = ref.watch(dutiesProvider);
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      
      // Header
      appBar: AppHeader(
        title: "Lớp CNTT K20",
        subtitle: "Lớp trưởng",
        onMenuPressed: () {},
      ),
      
      // Body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Title ---
            Text("Dashboard Lớp trưởng", style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Tổng quan hoạt động lớp học", style: GoogleFonts.roboto(color: Colors.grey, fontSize: 14)),
            
            const SizedBox(height: 16),

            // --- 2. Grid Thống kê (Xử lý AsyncValue) ---
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Lỗi: $err')),
              data: (stats) => GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.25,
                ),
                itemCount: stats.length,
                itemBuilder: (context, index) {
                  final item = stats[index];
                  // Logic map icon (nên đưa vào util hoặc model, nhưng để đây cho nhanh UI)
                  IconData iconData;
                  switch(item.iconCode) {
                    case 1: iconData = LucideIcons.users; break;
                    case 2: iconData = LucideIcons.calendar; break;
                    case 3: iconData = LucideIcons.dollarSign; break;
                    default: iconData = LucideIcons.box;
                  }
                  
                  return StatCard(
                    title: item.title,
                    value: item.value,
                    subValue: item.subValue,
                    color: Color(item.color),
                    icon: iconData,
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // --- 3. Nhiệm vụ trực nhật (Xử lý AsyncValue) ---
            _buildSectionTitle("Nhiệm vụ trực nhật"),
            dutiesAsync.when(
              loading: () => _buildLoadingSkeleton(),
              error: (err, stack) => Text('Không tải được nhiệm vụ: $err'),
              data: (duties) => Column(
                children: duties.map((duty) => DutyListItem(data: duty)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- 4. Sự kiện đang mở (Xử lý AsyncValue) ---
            _buildSectionTitle("Sự kiện đang mở"),
            eventsAsync.when(
              loading: () => _buildLoadingSkeleton(),
              error: (err, stack) => const SizedBox(), // Ẩn nếu lỗi
              data: (events) => Column(
                children: events.map((event) => EventCardItem(data: event)).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // --- 5. Sinh viên chưa nộp quỹ ---
            // (Phần này tạm thời vẫn Hardcode UI vì chưa tạo Provider riêng, 
            // nhưng tư duy sẽ tương tự như trên)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle("Sinh viên chưa nộp quỹ"),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50], 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Text("3 người", style: GoogleFonts.roboto(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 12),
            const UnpaidStudentItem(name: "Nguyễn Văn A", desc: "Quỹ lớp HK1", amount: "100.000đ"),
            const UnpaidStudentItem(name: "Trần Thị B", desc: "Quỹ lớp HK1", amount: "100.000đ"),
            const UnpaidStudentItem(name: "Lê Văn C", desc: "Quỹ lớp HK1", amount: "100.000đ"),
            
            const SizedBox(height: 40), 
          ],
        ),
      ),
      
      // Footer
      bottomNavigationBar: AppBottomNav(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() {
            _bottomNavIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  // Widget hiển thị lúc đang load danh sách (Loading Skeleton đơn giản)
  Widget _buildLoadingSkeleton() {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}