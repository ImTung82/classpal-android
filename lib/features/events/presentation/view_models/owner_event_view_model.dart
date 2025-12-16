import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/event_models.dart';
import '../../data/repositories/event_repository.dart';

// Provider lấy danh sách sự kiện cho Lớp trưởng
final ownerEventsProvider = FutureProvider<List<ClassEvent>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.fetchOwnerEvents();
});
