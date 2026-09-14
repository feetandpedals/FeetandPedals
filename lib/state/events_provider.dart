import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/event.dart';
import '../models/event_category.dart';
import 'repository_providers.dart';

final categoriesProvider = FutureProvider.autoDispose<List<EventCategoryTag>>((ref) {
  return ref.watch(eventRepositoryProvider).fetchCategories();
});

final featuredEventsProvider = FutureProvider.autoDispose<List<SportEvent>>((ref) {
  return ref.watch(eventRepositoryProvider).fetchFeaturedEvents();
});

final eventSearchQueryProvider = StateProvider<String>((ref) => '');
final eventCategoryFilterProvider = StateProvider<String?>((ref) => null);

final filteredEventsProvider = FutureProvider.autoDispose<List<SportEvent>>((ref) {
  final query = ref.watch(eventSearchQueryProvider);
  final category = ref.watch(eventCategoryFilterProvider);
  return ref.watch(eventRepositoryProvider).fetchEvents(query: query, categoryId: category);
});

final eventDetailProvider = FutureProvider.autoDispose.family<EventDetails, String>((ref, id) {
  return ref.watch(eventRepositoryProvider).fetchEventDetails(id);
});
