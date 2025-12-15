import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/join_class_repository.dart';

// 1. State
class JoinClassState {
  final bool isLoading;
  JoinClassState({this.isLoading = false});

  JoinClassState copyWith({bool? isLoading}) {
    return JoinClassState(isLoading: isLoading ?? this.isLoading);
  }
}

// 2. ViewModel
class JoinClassViewModel extends Notifier<JoinClassState> {
  @override
  JoinClassState build() => JoinClassState();

  Future<void> joinClass({
    required String code,
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final repository = ref.read(joinClassRepositoryProvider);
      await repository.joinClass(code);
      onSuccess();
    } catch (e) {
      onError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// 3. Provider
final joinClassViewModelProvider =
    NotifierProvider<JoinClassViewModel, JoinClassState>(() {
      return JoinClassViewModel();
    });
