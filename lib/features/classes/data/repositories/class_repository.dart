import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/class_model.dart';

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  return ClassRepository();
});

class ClassRepository {
  final _supabase = Supabase.instance.client;

  // --- 1. LẤY DANH SÁCH LỚP ---
  Future<List<ClassModel>> fetchUserClasses() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('class_members')
        .select('role, classes(*)') 
        .eq('user_id', user.id)
        .eq('is_active', true)
        .order('joined_at', ascending: false);

    final List<dynamic> data = response as List<dynamic>;
    return data.map((e) => ClassModel.fromMap(e)).toList();
  }

  // --- 2. TẠO LỚP HỌC (CÓ CẬP NHẬT) ---
  // [SỬA] Thêm tham số ownerStudentCode
  Future<void> createClass(ClassModel newClass, String ownerStudentCode) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    // Bước 1: Insert vào bảng classes
    final List<dynamic> res = await _supabase
        .from('classes')
        .insert(newClass.toJson())
        .select();
    
    final createdClassId = res.first['id'];

    // Bước 2: Add người tạo vào bảng members
    // [SỬA] Lưu mã sinh viên chính chủ vào đây
    await _supabase.from('class_members').insert({
      'class_id': createdClassId,
      'user_id': user.id,
      'role': 'owner',
      'student_code': ownerStudentCode, 
      'is_active': true,
    });
  }

  // --- 3. THAM GIA LỚP ---
  Future<void> joinClass(String classCode, String studentCode) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Chưa đăng nhập");

    final response = await _supabase
        .from('classes')
        .select('id')
        .eq('code', classCode.toUpperCase())
        .maybeSingle();

    if (response == null) {
      throw Exception("Mã lớp không tồn tại. Vui lòng kiểm tra lại.");
    }

    try {
      await _supabase.from('class_members').insert({
        'class_id': response['id'],
        'user_id': user.id,
        'student_code': studentCode,
        'role': 'student',
        'is_active': true,
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception("Bạn đã ở trong lớp này hoặc Mã SV bị trùng.");
      }
      rethrow;
    }
  }
}