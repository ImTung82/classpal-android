import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/notification_view_model.dart';

class CreateNotification extends ConsumerStatefulWidget {
  final String classId;

  const CreateNotification({super.key, required this.classId});

  @override
  ConsumerState<CreateNotification> createState() =>
      _CreateNotificationState();
}

class _CreateNotificationState
    extends ConsumerState<CreateNotification> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  String _type = 'general';
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Text(
        'Tạo thông báo mới',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ===== Tiêu đề =====
                _label('Tiêu đề'),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDecoration(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    if (v.trim().length < 3) {
                      return 'Tiêu đề quá ngắn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// ===== Nội dung =====
                _label('Nội dung'),
                TextFormField(
                  controller: _bodyCtrl,
                  maxLines: 3,
                  decoration: _inputDecoration(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập nội dung';
                    }
                    if (v.trim().length < 5) {
                      return 'Nội dung quá ngắn';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                /// ===== Loại thông báo =====
                _label('Loại thông báo'),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: _inputDecoration(),
                  items: const [
                    DropdownMenuItem(
                      value: 'general',
                      child: Text('Thông báo chung'),
                    ),
                    DropdownMenuItem(
                      value: 'event_reminder',
                      child: Text('Nhắc sự kiện'),
                    ),
                    DropdownMenuItem(
                      value: 'duty_reminder',
                      child: Text('Nhắc trực nhật'),
                    ),
                    DropdownMenuItem(
                      value: 'fund_reminder',
                      child: Text('Nhắc đóng quỹ'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _type = v!),
                ),
              ],
            ),
          ),
        ),
      ),
      actionsPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      actions: [
        OutlinedButton(
          onPressed: _loading ? null : () => Navigator.pop(context),
          child: const Text('Huỷ'),
        ),
        ElevatedButton(
          onPressed: _loading
              ? null
              : () async {
                  
                  if (!_formKey.currentState!.validate()) return;

                  setState(() => _loading = true);

                  final create =
                      ref.read(createNotificationProvider);

                  await create(
                    classId: widget.classId,
                    title: _titleCtrl.text.trim(),
                    body: _bodyCtrl.text.trim(),
                    type: _type,
                  );

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
          ),
          child: _loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Gửi',
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ],
    );
  }
}
