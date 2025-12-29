import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

// --- STATE MODEL ---
class AppAuthState {
  final bool isLoginMode;
  final bool isPasswordVisible;
  final bool isLoading;

  AppAuthState({
    this.isLoginMode = true,
    this.isPasswordVisible = false,
    this.isLoading = false,
  });

  AppAuthState copyWith({bool? isLoginMode, bool? isPasswordVisible, bool? isLoading}) {
    return AppAuthState(
      isLoginMode: isLoginMode ?? this.isLoginMode,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- VIEW MODEL ---
class AuthViewModel extends Notifier<AppAuthState> {
  
  @override
  AppAuthState build() {
    return AppAuthState(); 
  }

  void toggleAuthMode() {
    state = state.copyWith(isLoginMode: !state.isLoginMode);
  }

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<void> submit({
    required String email,
    required String password,
    String? name,
    String? phone, // [CẬP NHẬT] Thêm tham số phone
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      onError("Vui lòng nhập đầy đủ email và mật khẩu");
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final authRepository = ref.read(authRepositoryProvider);

      if (state.isLoginMode) {
        // ĐĂNG NHẬP
        await authRepository.signIn(email, password);
        onSuccess("Đăng nhập thành công!");
      } else {
        // ĐĂNG KÝ
        // [CẬP NHẬT] Validate thêm tên và sđt
        if (name == null || name.isEmpty) {
          throw const AuthException("Vui lòng nhập họ tên");
        }
        if (phone == null || phone.isEmpty) {
           throw const AuthException("Vui lòng nhập số điện thoại");
        }
        
        // Truyền phone xuống repo
        await authRepository.signUp(email, password, name, phone);
        onSuccess("Đăng ký thành công!");
      }
    } on AuthException catch (e) {
      onError(e.message);
    } catch (e) {
      onError("Lỗi không xác định: $e");
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).signOut();
    } catch (e) {
      // Bỏ qua lỗi nếu có
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AppAuthState>(() {
  return AuthViewModel();
});