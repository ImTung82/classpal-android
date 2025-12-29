import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/repositories/auth_repository.dart';

class AppAuthState {
  final bool isLoginMode;
  final bool isPasswordVisible;
  final bool isLoading;
  final bool isRecoveryMode;

  AppAuthState({
    this.isLoginMode = true,
    this.isPasswordVisible = false,
    this.isLoading = false,
    this.isRecoveryMode = false,
  });

  AppAuthState copyWith({
    bool? isLoginMode,
    bool? isPasswordVisible,
    bool? isLoading,
    bool? isRecoveryMode,
  }) {
    return AppAuthState(
      isLoginMode: isLoginMode ?? this.isLoginMode,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      isLoading: isLoading ?? this.isLoading,
      isRecoveryMode: isRecoveryMode ?? this.isRecoveryMode,
    );
  }
}

class AuthViewModel extends Notifier<AppAuthState> {
  StreamSubscription<AuthState>? _authSubscription;

  @override
  AppAuthState build() {
    _listenToAuthEvents();

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return AppAuthState();
  }

  void _listenToAuthEvents() {
    final supabase = Supabase.instance.client;
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.passwordRecovery) {
        state = state.copyWith(isRecoveryMode: true);
      }
    });
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
    String? phone,
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
        await authRepository.signIn(email, password);
        onSuccess("Đăng nhập thành công!");
      } else {
        if (name == null || name.isEmpty) {
          throw const AuthException("Vui lòng nhập họ tên");
        }
        if (phone == null || phone.isEmpty) {
          throw const AuthException("Vui lòng nhập số điện thoại");
        }

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
      // Ignore error
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> sendPasswordReset({
    required String email,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    if (email.isEmpty) {
      onError("Vui lòng nhập email");
      return;
    }
    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      onSuccess(
        "Đã gửi email! Vui lòng kiểm tra hộp thư và bấm vào liên kết để đổi mật khẩu.",
      );
    } catch (e) {
      onError("Lỗi: ${e.toString()}");
    }
  }

  Future<void> submitNewPassword({
    required String newPassword,
    required Function() onSuccess,
    required Function(String) onError,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      await ref.read(authRepositoryProvider).updatePassword(newPassword);
      state = state.copyWith(isRecoveryMode: false, isLoading: false);
      onSuccess();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      onError("Không thể đổi mật khẩu: ${e.toString()}");
    }
  }
}

final authViewModelProvider = NotifierProvider<AuthViewModel, AppAuthState>(() {
  return AuthViewModel();
});
