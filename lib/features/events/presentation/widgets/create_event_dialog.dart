import 'package:flutter/material.dart';
import '../../data/models/event_models.dart';

class CreateEventDialog extends StatefulWidget {
  const CreateEventDialog({super.key});

  @override
  State<CreateEventDialog> createState() => _CreateEventDialogState();
}

class _CreateEventDialogState extends State<CreateEventDialog> {
  // Key để quản lý trạng thái Form và thực hiện Validate
  final _formKey = GlobalKey<FormState>();

  // Controllers để lấy dữ liệu text
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();

  // Biến trạng thái cho Checkbox
  bool _isMandatory = false;

  // --- LOGIC CHỌN NGÀY ---
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF155DFC), // Màu chủ đạo của app
            colorScheme: const ColorScheme.light(primary: Color(0xFF155DFC)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // --- LOGIC CHỌN GIỜ ---
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        // Format giờ phút cho đẹp (thêm số 0 đằng trước nếu < 10)
        final hour = picked.hour.toString().padLeft(2, '0');
        final minute = picked.minute.toString().padLeft(2, '0');
        _timeController.text = "$hour:$minute";
      });
    }
  }

  // --- LOGIC NÚT TẠO SỰ KIỆN ---
  void _onSubmit() {
    if (_formKey.currentState!.validate()) {
      // Tạo object ClassEvent
      final newEvent = ClassEvent(
        id: '', // Server sẽ tự gen
        title: _nameController.text.trim(),
        description: _descController.text.trim(),
        date: _dateController.text,
        time: _timeController.text,
        location: _locationController.text.trim(),
        isMandatory: _isMandatory,
      );

      // Trả về object thay vì true
      Navigator.of(context).pop(newEvent);
    }
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      // Dialog bao bọc nội dung
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
            // Form bao bọc các input để validate
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Tạo sự kiện mới',
                    style: TextStyle(
                      fontSize: 20, // Tăng size cho giống header
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF101727),
                      fontFamily: 'Arimo',
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 1. Tên sự kiện
                  _buildLabel('Tên sự kiện'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'VD: Hội thảo Khởi nghiệp 2024',
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Vui lòng nhập tên'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // 2. Mô tả
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

                  // 3. Ngày và Giờ (Chung 1 dòng)
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
                              hint: 'dd/mm/yyyy',
                              readOnly: true, // Không cho nhập tay
                              onTap: _pickDate,
                              icon: Icons.calendar_today_outlined,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Chọn ngày'
                                  : null,
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
                              hint: '--:--',
                              readOnly: true, // Không cho nhập tay
                              onTap: _pickTime,
                              icon: Icons.access_time,
                              validator: (val) => (val == null || val.isEmpty)
                                  ? 'Chọn giờ'
                                  : null,
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
                    hint: 'VD: Hội trường A',
                    validator: (val) => (val == null || val.isEmpty)
                        ? 'Vui lòng nhập địa điểm'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // 5. Checkbox "Sự kiện bắt buộc" (Custom UI)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isMandatory = !_isMandatory;
                      });
                    },
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
                            fontFamily: 'Arimo',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 6. Action Buttons
                  Row(
                    children: [
                      // Nút Hủy
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Đóng dialog, không làm gì cả
                            Navigator.of(context).pop();
                          },
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
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Tạo sự kiện
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF155DFC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
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

  // --- WIDGET HELPER ĐỂ CODE GỌN HƠN ---

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
    required String hint,
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
        hintText: hint,
        hintStyle: TextStyle(color: Colors.black.withOpacity(0.3)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        suffixIcon: icon != null
            ? Icon(icon, color: const Color(0xFF9CA3AF))
            : null,
        // Viền mặc định
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD0D5DB)),
        ),
        // Viền khi focus (màu xanh)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF155DFC), width: 1.5),
        ),
        // Viền khi lỗi (màu đỏ)
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
