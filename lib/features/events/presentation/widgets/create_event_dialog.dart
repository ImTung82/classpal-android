import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_models.dart';

class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();

  // --- State cho Thời gian ---
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 9, minute: 0);

  // --- State cho Hạn đăng ký ---
  DateTime _deadlineDate = DateTime.now();
  TimeOfDay _deadlineTime = const TimeOfDay(hour: 23, minute: 59);

  bool _isMandatory = false;

  @override
  void initState() {
    super.initState();
    // Mặc định là ngày hôm nay, nhưng đảm bảo không chọn được quá khứ qua firstDate
    final now = DateTime.now();
    _selectedDate = now;
    _deadlineDate = now;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- HELPER CHỌN NGÀY/GIỜ ---
  Future<void> _pickDate(BuildContext context, bool isEventDate) async {
    final now = DateTime.now();
    final today = DateTime(
      now.year,
      now.month,
      now.day,
    ); // Mốc ngày hôm nay 00:00

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isEventDate ? _selectedDate : _deadlineDate,
      firstDate: today, // [YÊU CẦU] Chặn chọn ngày trước ngày hôm nay
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF155DFC),
            colorScheme: const ColorScheme.light(primary: Color(0xFF155DFC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isEventDate) {
          _selectedDate = picked;
          if (_deadlineDate.isBefore(picked)) {
            _deadlineDate = picked;
          }
        } else {
          _deadlineDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    Function(TimeOfDay) onPicked,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF155DFC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => onPicked(picked));
    }
  }

  // --- SUBMIT ---
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Tạo DateTime từ các thành phần đã chọn (Giờ địa phương)
      final startDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final deadlineDateTime = DateTime(
        _deadlineDate.year,
        _deadlineDate.month,
        _deadlineDate.day,
        _deadlineTime.hour,
        _deadlineTime.minute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // [YÊU CẦU] Fix lỗi 7 tiếng bằng cách chuyển sang UTC trước khi lưu
      final newEvent = ClassEvent(
        id: '',
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        startTime: startDateTime.toUtc(), // CHUYỂN SANG UTC
        endTime: endDateTime.toUtc(), // CHUYỂN SANG UTC
        registrationDeadline: deadlineDateTime.toUtc(), // CHUYỂN SANG UTC
        location: _locationController.text.trim(),
        isMandatory: _isMandatory,
      );

      Navigator.of(context).pop(newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'Tạo sự kiện mới',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF101727),
                        fontFamily: 'Arimo',
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildLabel('Tên sự kiện'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'VD: Hội thảo Khởi nghiệp...',
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Vui lòng nhập tên'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Mô tả'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    hint: 'Mô tả về sự kiện...',
                    maxLines: 3,
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Vui lòng nhập mô tả'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Thời gian diễn ra'),
                  const SizedBox(height: 8),
                  _buildDateTimePicker(
                    text:
                        "Ngày: ${DateFormat('dd/MM/yyyy').format(_selectedDate)}",
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _pickDate(context, true),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateTimePicker(
                          text: "Bắt đầu: ${_startTime.format(context)}",
                          onTap: () =>
                              _pickTime(context, (t) => _startTime = t),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimePicker(
                          text: "Kết thúc: ${_endTime.format(context)}",
                          onTap: () => _pickTime(context, (t) => _endTime = t),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 18,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Hạn đăng ký',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.red[700],
                          fontFamily: 'Arimo',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _buildDateTimePicker(
                          text: DateFormat('dd/MM/yyyy').format(_deadlineDate),
                          icon: Icons.event_busy,
                          onTap: () => _pickDate(context, false),
                          borderColor: Colors.red.shade200,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: _buildDateTimePicker(
                          text: _deadlineTime.format(context),
                          onTap: () =>
                              _pickTime(context, (t) => _deadlineTime = t),
                          borderColor: Colors.red.shade200,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Địa điểm'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    hint: 'VD: Hội trường A',
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Vui lòng nhập địa điểm'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => setState(() => _isMandatory = !_isMandatory),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: _isMandatory
                                  ? const Color(0xFF155DFC)
                                  : const Color(0xFFD0D5DB),
                              width: 1.5,
                            ),
                            color: _isMandatory
                                ? const Color(0xFF155DFC)
                                : Colors.white,
                          ),
                          child: _isMandatory
                              ? const Icon(
                                  Icons.check,
                                  size: 16,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        _buildLabel('Sự kiện bắt buộc'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFD0D5DB)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF354152),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF155DFC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Tạo sự kiện',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        color: Color(0xFF354152),
        fontFamily: 'Arimo',
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String text,
    IconData? icon,
    required VoidCallback onTap,
    Color? borderColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: borderColor ?? const Color(0xFFD0D5DB),
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, color: Color(0xFF101727)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 4),
              Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF101727)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
