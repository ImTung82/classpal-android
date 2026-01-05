import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../teams/data/models/team_model.dart';
import '../../../teams/presentation/view_models/team_view_model.dart';
import '../view_models/duty_view_model.dart';

class CreateDutyDialog extends ConsumerStatefulWidget {
  final String classId;
  const CreateDutyDialog({super.key, required this.classId});

  @override
  ConsumerState<CreateDutyDialog> createState() => _CreateDutyDialogState();
}

class _CreateDutyDialogState extends ConsumerState<CreateDutyDialog> {
  // Giữ nguyên các biến state của bạn
  final Set<String> _selectedTeamIds = {};
  DateTime _selectedDate = DateTime.now();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // LOGIC SUBMIT MỚI: Khớp với createDutyRotation
  Future<void> _submitData() async {
    final String title = _titleController.text.trim().isEmpty
        ? "Trực nhật"
        : _titleController.text.trim();
    final String desc = _descriptionController.text.trim();

    // Tách danh sách nhiệm vụ nếu LT nhập dạng "Lau bảng, Tắt điện"
    List<String> taskTitles = title
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    // Nếu có description, nối vào từng nhiệm vụ
    if (desc.isNotEmpty) {
      taskTitles = taskTitles.map((t) => "$t: $desc").toList();
    }

    await ref
        .read(dutyControllerProvider.notifier)
        .createDuty(
          classId: widget.classId,
          startDate: _selectedDate,
          taskTitles: taskTitles,
          onSuccess: () {
            if (mounted) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Tạo nhiệm vụ thành công!"),
                backgroundColor: Colors.green,
              ),
            );
          },
          onError: (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Lỗi: $e"), backgroundColor: Colors.red),
            );
          },
        );
  }

  @override
  Widget build(BuildContext context) {
    final teamsAsync = ref.watch(teamGroupsProvider(widget.classId));
    final isLoading = ref.watch(dutyControllerProvider).isLoading;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          width: 342,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tạo nhiệm vụ mới',
                  style: GoogleFonts.arimo(
                    color: const Color(0xFF101727),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                _buildSectionTitle('Tên nhiệm vụ'),
                _buildTextField(_titleController, 'VD: Trực nhật, Lau bảng...'),
                const SizedBox(height: 16),

                _buildSectionTitle('Mô tả công việc'),
                _buildTextField(
                  _descriptionController,
                  'Nhập nội dung (VD: Tắt điện, quạt...)',
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                _buildSectionTitle('Ngày thực hiện'),
                _buildDatePickerTrigger(),
                const SizedBox(height: 20),

                _buildSectionTitle('Chọn tổ phụ trách'),
                teamsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (e, _) => Text("Lỗi tải tổ: $e"),
                  data: (teams) => _buildTeamsGrid(teams),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: _buildActionButton(
                          'Hủy',
                          bgColor: Colors.white,
                          textColor: const Color(0xFF354152),
                          hasBorder: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: isLoading ? null : _submitData,
                        child: _buildActionButton(
                          isLoading ? 'Đang tạo...' : 'Tạo nhiệm vụ',
                          bgColor: const Color(0xFF155DFC),
                          textColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // GIỮ NGUYÊN CÁC HÀM BUILD WIDGET CSS CỦA BẠN
  Widget _buildTeamsGrid(List<TeamGroup> teams) {
    if (teams.isEmpty) return const Text("Chưa có tổ nào trong lớp");
    int crossAxisCount = teams.length == 1 ? 1 : (teams.length == 3 ? 3 : 2);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: teams.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        mainAxisExtent: 44,
      ),
      itemBuilder: (context, index) {
        final team = teams[index];
        final isSelected = _selectedTeamIds.contains(team.id);
        return GestureDetector(
          onTap: () => setState(
            () => isSelected
                ? _selectedTeamIds.remove(team.id)
                : _selectedTeamIds.add(team.id),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF155DFC).withOpacity(0.08)
                  : const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF155DFC)
                    : const Color(0xFFD0D5DB),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                team.name,
                style: GoogleFonts.arimo(
                  color: isSelected
                      ? const Color(0xFF155DFC)
                      : const Color(0xFF101727),
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.arimo(
          color: const Color(0xFF354152),
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.arimo(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.arimo(color: Colors.grey, fontSize: 14),
        contentPadding: const EdgeInsets.all(12),
        isDense: true,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDatePickerTrigger() {
    return InkWell(
      onTap: _pickDate,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFD0D5DB)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFF354152),
            ),
            const SizedBox(width: 10),
            Text(
              "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
              style: GoogleFonts.arimo(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label, {
    required Color bgColor,
    required Color textColor,
    bool hasBorder = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: hasBorder ? Border.all(color: const Color(0xFFD0D5DB)) : null,
      ),
      child: Center(
        child: Text(
          label,
          style: GoogleFonts.arimo(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2030),
      selectableDayPredicate: (DateTime val) => val.weekday == DateTime.monday,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
