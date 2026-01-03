import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/event_models.dart';

class EditEventDialog extends StatefulWidget {
  final ClassEvent event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _locationController;

  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late DateTime _deadlineDate;
  late TimeOfDay _deadlineTime;

  late bool _isMandatory;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.title);
    _descController = TextEditingController(text: widget.event.description);
    _locationController = TextEditingController(text: widget.event.location);
    _isMandatory = widget.event.isMandatory;

    // Chuyển về Local time để hiển thị đúng trên UI khi bắt đầu edit
    _selectedDate = widget.event.startTime.toLocal();
    _startTime = TimeOfDay.fromDateTime(widget.event.startTime.toLocal());

    if (widget.event.endTime != null) {
      _endTime = TimeOfDay.fromDateTime(widget.event.endTime!.toLocal());
    } else {
      _endTime = TimeOfDay(
        hour: (_startTime.hour + 2) % 24,
        minute: _startTime.minute,
      );
    }

    _deadlineDate = widget.event.registrationDeadline.toLocal();
    _deadlineTime = TimeOfDay.fromDateTime(
      widget.event.registrationDeadline.toLocal(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context, bool isEventDate) async {
    final now = DateTime.now();
    // Tạo ngày hôm nay (00:00:00) để làm mốc so sánh cho firstDate
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: isEventDate ? _selectedDate : _deadlineDate,
      firstDate: today, // Chặn chọn các ngày trong quá khứ
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
          // Nếu ngày sự kiện thay đổi mà nhỏ hơn hạn đăng ký hiện tại,
          // có thể cần điều chỉnh hạn đăng ký (tùy logic nghiệp vụ)
        } else {
          _deadlineDate = picked;
        }
      });
    }
  }

  Future<void> _pickTime(
    BuildContext context,
    Function(TimeOfDay) onPicked,
    TimeOfDay initialTime,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
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

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Gộp ngày và giờ (Local Time)
      final startDateTimeLocal = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _startTime.hour,
        _startTime.minute,
      );

      final endDateTimeLocal = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _endTime.hour,
        _endTime.minute,
      );

      final deadlineDateTimeLocal = DateTime(
        _deadlineDate.year,
        _deadlineDate.month,
        _deadlineDate.day,
        _deadlineTime.hour,
        _deadlineTime.minute,
      );

      // Kiểm tra logic thời gian
      if (endDateTimeLocal.isBefore(startDateTimeLocal)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // [SỬA LỖI] Sử dụng .toUtc() trước khi đóng gói dữ liệu để gửi lên Server
      final updatedEvent = widget.event.copyWith(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        location: _locationController.text.trim(),
        startTime: startDateTimeLocal.toUtc(),
        endTime: endDateTimeLocal.toUtc(),
        registrationDeadline: deadlineDateTimeLocal.toUtc(),
        isMandatory: _isMandatory,
      );

      Navigator.of(context).pop(updatedEvent);
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
                      'Chỉnh sửa sự kiện',
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Mô tả'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    maxLines: 3,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Vui lòng nhập mô tả' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Thời gian sự kiện'),
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
                          onTap: () => _pickTime(
                            context,
                            (t) => _startTime = t,
                            _startTime,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateTimePicker(
                          text: "Kết thúc: ${_endTime.format(context)}",
                          onTap: () =>
                              _pickTime(context, (t) => _endTime = t, _endTime),
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
                        'Chỉnh sửa hạn đăng ký',
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
                          onTap: () => _pickTime(
                            context,
                            (t) => _deadlineTime = t,
                            _deadlineTime,
                          ),
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
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Nhập địa điểm' : null,
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
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF155DFC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF101727)),
      decoration: InputDecoration(
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
