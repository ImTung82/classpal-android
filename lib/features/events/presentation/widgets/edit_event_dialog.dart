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
  late TextEditingController _timeController;
  late TextEditingController _locationController;

  // State variables
  late bool _isMandatory;
  late bool _isOpen; // True: Đang mở, False: Đã đóng

  @override
  void initState() {
    super.initState();
    // 1. Điền dữ liệu cũ vào form (Pre-fill)
    _nameController = TextEditingController(text: widget.event.title);
    _descController = TextEditingController(text: widget.event.description);
    _dateController = TextEditingController(text: widget.event.date);
    _timeController = TextEditingController(text: widget.event.time);
    _locationController = TextEditingController(text: widget.event.location);

    _isMandatory = widget.event.isMandatory;
    _isOpen = widget.event.isOpen;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _dateController.dispose();
    _timeController.dispose();
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

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  // --- LOGIC LƯU THAY ĐỔI ---
  void _onSave() {
    if (_formKey.currentState!.validate()) {
      // Đóng dialog và trả về true để báo thành công
      Navigator.of(context).pop(true);
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

                  // 3. Ngày - Giờ
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
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Giờ'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _timeController,
                              readOnly: true,
                              onTap: _pickTime,
                              icon: Icons.access_time,
                              validator: (v) => v!.isEmpty ? 'Chọn giờ' : null,
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

                  // 6. Trạng thái (Đang mở / Đã đóng)
                  _buildLabel('Trạng thái'),
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
                        ), // Line ngăn cách
                        _buildRadioOption("Đã đóng", false),
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
