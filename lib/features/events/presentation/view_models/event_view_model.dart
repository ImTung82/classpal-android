import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider quản lý danh sách sự kiện (AsyncValue)
final eventsProvider = FutureProvider<List<ClassEvent>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.fetchEvents();
});
