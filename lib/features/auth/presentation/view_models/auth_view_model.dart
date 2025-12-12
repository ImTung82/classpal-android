import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

// 1. State (Giữ nguyên)
class AuthState {
  final bool isLoginMode;
  final bool isPasswordVisible;
  final bool isLoading;

  AuthState({
    this.isLoginMode = true,
    this.isPasswordVisible = false,
    this.isLoading = false,
  });

  AuthState copyWith({bool? isLoginMode, bool? isPasswordVisible, bool? isLoading}) {
    return AuthState(
      isLoginMode: isLoginMode ?? this.isLoginMode,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. ViewModel (Dùng Syntax mới: Notifier)
class AuthViewModel extends Notifier<AuthState> {
  
  // Hàm build() thay thế cho Constructor để khởi tạo State ban đầu
  @override
  AuthState build() {
    return AuthState(); 
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
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    // Lấy Repository thông qua ref (có sẵn trong Notifier)
    final repository = ref.read(authRepositoryProvider);

    state = state.copyWith(isLoading: true);
    try {
      if (state.isLoginMode) {
        await repository.login(email, password);
        onSuccess("Đăng nhập thành công!");
      } else {
        await repository.register(name ?? "", email, password);
        onSuccess("Đăng ký thành công!");
      }
    } catch (e) {
      onError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      // Kiểm tra mounted trước khi set state để tránh lỗi async
      // (Tuy nhiên trong Riverpod Notifier, việc set state an toàn hơn)
      state = state.copyWith(isLoading: false);
    }
  }
}

// 3. Provider (Dùng NotifierProvider thay vì StateNotifierProvider)
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});