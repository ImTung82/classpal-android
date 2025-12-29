import 'package:flutter/material.dart';
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
  late TextEditingController _dateController;
  late TextEditingController _timeStartController;
  late TextEditingController _timeEndController;
  late TextEditingController _locationController;

  late bool _isMandatory;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.title);
    _descController = TextEditingController(text: widget.event.description);
    _dateController = TextEditingController(text: widget.event.date);

    // Parse time string safely
    final timeText = widget.event.time.trim();
    if (timeText.contains(' - ')) {
      final timeParts = timeText.split(' - ');
      _timeStartController = TextEditingController(text: timeParts[0].trim());
      _timeEndController = TextEditingController(text: timeParts[1].trim());
    } else {
      _timeStartController = TextEditingController(text: timeText);
      _timeEndController = TextEditingController();
    }

    _locationController = TextEditingController(text: widget.event.location);
    _isMandatory = widget.event.isMandatory;
    _isOpen = widget.event.isOpen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    DateTime initialDate = DateTime.now();
    try {
      if (_dateController.text.isNotEmpty) {
        final parts = _dateController.text.split('/');
        if (parts.length == 3) {
          initialDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      }
    } catch (e) {
      initialDate = DateTime.now();
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickStartTime() async {
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      if (_timeStartController.text.isNotEmpty) {
        final parts = _timeStartController.text.split(':');
        if (parts.length == 2) {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeStartController.text = "$hour:$minute";
      });
    }
  }

  Future<void> _pickEndTime() async {
    TimeOfDay initialTime = TimeOfDay.now();
    try {
      if (_timeEndController.text.isNotEmpty) {
        final parts = _timeEndController.text.split(':');
        if (parts.length == 2) {
          initialTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      }
    } catch (e) {
      initialTime = TimeOfDay.now();
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeEndController.text = "$hour:$minute";
      });
    }
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      if (_timeEndController.text.isNotEmpty) {
        try {
          final startParts = _timeStartController.text.split(':');
          final endParts = _timeEndController.text.split(':');
          final startMinutes =
              int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
          final endMinutes =
              int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

          if (endMinutes <= startMinutes) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Giờ kết thúc phải sau giờ bắt đầu'),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Định dạng giờ không hợp lệ'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      String timeString = _timeStartController.text.trim();
      if (_timeEndController.text.isNotEmpty) {
        timeString += " - ${_timeEndController.text.trim()}";
      }

      final updatedEvent = widget.event.copyWith(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        date: _dateController.text.trim(),
        time: timeString,
        location: _locationController.text.trim(),
        isMandatory: _isMandatory,
        isOpen: _isOpen,
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 24),

                  _buildLabel('Tên sự kiện'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Mô tả'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Ngày'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: _pickDate,
                    icon: Icons.calendar_today_outlined,
                    validator: (v) => v!.isEmpty ? 'Chọn ngày' : null,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Giờ bắt đầu'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _timeStartController,
                              readOnly: true,
                              onTap: _pickStartTime,
                              icon: Icons.access_time,
                              validator: (v) => v!.isEmpty ? 'Chọn giờ' : null,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Giờ kết thúc'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _timeEndController,
                              readOnly: true,
                              onTap: _pickEndTime,
                              icon: Icons.access_time,
                              hintText: 'Tùy chọn',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildLabel('Địa điểm'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    validator: (v) => v!.isEmpty ? 'Nhập địa điểm' : null,
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
                        const Text(
                          'Sự kiện bắt buộc',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF354152),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildLabel('Trạng thái sự kiện'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D5DB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildRadioOption("Đang mở", true),
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFD0D5DB),
                        ),
                        _buildRadioOption("Đã đóng", false),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

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
                            elevation: 0,
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

  Widget _buildTextField({
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: const TextStyle(fontSize: 16, color: Color(0xFF101727)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9CA3AF))
            : null,
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

  Widget _buildRadioOption(String label, bool value) {
    final isSelected = _isOpen == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _isOpen = value),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0E7FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(value ? 0 : 0),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? const Color(0xFF155DFC)
                  : const Color(0xFF354152),
            ),
          ),
        ),
      ),
    );
  }
}
