import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/create_class_repository.dart';

// 1. State: Quản lý trạng thái loading
class CreateClassState {
  final bool isLoading;
  CreateClassState({this.isLoading = false});

  CreateClassState copyWith({bool? isLoading}) {
    return CreateClassState(isLoading: isLoading ?? this.isLoading);
  }
}

// 2. ViewModel: Xử lý Logic
class CreateClassViewModel extends Notifier<CreateClassState> {
  @override
  CreateClassState build() => CreateClassState();

  Future<void> createClass({
    required String className,
    required Function() onSuccess,
    required Function(String message) onError,
  }) async {
    // Bật loading
    state = state.copyWith(isLoading: true);

    try {
      // Gọi Repository
      final repository = ref.read(createClassRepositoryProvider);
      await repository.createClass(className);

      // Thành công
      onSuccess();
    } catch (e) {
      // Thất bại
      onError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      // Tắt loading
      state = state.copyWith(isLoading: false);
    }
  }
}

// 3. Provider
final createClassViewModelProvider =
    NotifierProvider<CreateClassViewModel, CreateClassState>(() {
      return CreateClassViewModel();
    });
