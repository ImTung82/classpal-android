import 'package:flutter/material.dart';
import '../../data/models/event_models.dart'; // Import model để lấy dữ liệu

class EditEventDialog extends StatefulWidget {
  // Nhận vào sự kiện cần sửa
  final ClassEvent event;

  const EditEventDialog({super.key, required this.event});

  @override
  State<EditEventDialog> createState() => _EditEventDialogState();
}

class _EditEventDialogState extends State<EditEventDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _dateController;
  late TextEditingController _timeStartController; // ✅ Đổi tên
  late TextEditingController _timeEndController; // ✅ THÊM MỚI
  late TextEditingController _locationController;

  // State variables
  late bool _isMandatory; // Sự kiện bắt buộc
  late bool _isOpen; // Trạng thái Đóng/Mở

  @override
  void initState() {
    super.initState();
    // 1. Điền dữ liệu cũ vào form (Pre-fill)
    _nameController = TextEditingController(text: widget.event.title);
    _descController = TextEditingController(text: widget.event.description);
    _dateController = TextEditingController(text: widget.event.date);
    // Parse time string
    final timeParts = widget.event.time.split(' - ');
    _timeStartController = TextEditingController(text: timeParts[0]);
    _timeEndController = TextEditingController(
      text: timeParts.length > 1 ? timeParts[1] : '',
    );
    _locationController = TextEditingController(text: widget.event.location);

    _isMandatory = widget.event.isMandatory; // ✅ Từ is_mandatory
    _isOpen = widget.event.isOpen; // ✅ Tính từ end_time
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _timeStartController.dispose();
    _timeEndController.dispose(); // ✅ THÊM
    _locationController.dispose();
    super.dispose();
  }

  // --- LOGIC DATE/TIME (Giống Create) ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // ✅ THÊM LOGIC CHỌN GIỜ BẮT ĐẦU
  Future<void> _pickStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeStartController.text = "$hour:$minute";
      });
    }
  }

  // ✅ THÊM LOGIC CHỌN GIỜ KẾT THÚC
  Future<void> _pickEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeEndController.text = "$hour:$minute";
      });
    }
  }

  // --- LOGIC LƯU THAY ĐỔI ---
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // ✅ Tạo chuỗi time kết hợp start - end
      String timeString = _timeStartController.text;
      if (_timeEndController.text.isNotEmpty) {
        timeString += " - ${_timeEndController.text}";
      }

      // Tạo object ClassEvent với dữ liệu đã sửa
      final updatedEvent = widget.event.copyWith(
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        date: _dateController.text,
        time: timeString, // ✅ Sử dụng chuỗi kết hợp
        location: _locationController.text.trim(),
        isMandatory: _isMandatory,
        isOpen: _isOpen,
      );

      // Trả về object thay vì true
      Navigator.of(context).pop(updatedEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ẩn bàn phím khi nhấn ra ngoài
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
                  // Header
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

                  // 1. Tên sự kiện
                  _buildLabel('Tên sự kiện'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập tên' : null,
                  ),
                  const SizedBox(height: 16),

                  // 2. Mô tả
                  _buildLabel('Mô tả'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _descController,
                    maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Vui lòng nhập mô tả' : null,
                  ),
                  const SizedBox(height: 16),

                  // 3. Ngày - Giờ bắt đầu - Giờ kết thúc
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Ngày'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _dateController,
                              readOnly: true,
                              onTap: _pickDate,
                              icon: Icons.calendar_today_outlined,
                              validator: (v) => v!.isEmpty ? 'Chọn ngày' : null,
                            ),
                          ],
                        ),
                      ),
                    ],
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

                  // 4. Địa điểm
                  _buildLabel('Địa điểm'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _locationController,
                    validator: (v) => v!.isEmpty ? 'Nhập địa điểm' : null,
                  ),
                  const SizedBox(height: 16),

                  // 5. Checkbox "Sự kiện bắt buộc"
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
                          'Sự kiện bắt buộc', // ✅ ĐÚNG LABEL
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF354152),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 6. Trạng thái Đóng/Mở (Radio buttons)
                  _buildLabel('Trạng thái sự kiện'), // ✅ LABEL MỚI
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD0D5DB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        _buildRadioOption("Đang mở", true), // ✅ ĐÚNG LABEL
                        Container(
                          width: 1,
                          height: 40,
                          color: const Color(0xFFD0D5DB),
                        ),
                        _buildRadioOption("Đã đóng", false), // ✅ ĐÚNG LABEL
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 7. Buttons
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

  // --- HELPER WIDGETS ---

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

  // Widget lựa chọn trạng thái
  Widget _buildRadioOption(String label, bool value) {
    final isSelected = _isOpen == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _isOpen = value),
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFE0E7FF)
                : Colors.transparent, // Màu nền nhẹ khi chọn
            borderRadius: BorderRadius.circular(
              value ? 0 : 0,
            ), // Có thể bo góc nếu ở 2 đầu
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
