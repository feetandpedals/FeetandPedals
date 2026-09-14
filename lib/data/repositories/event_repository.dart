import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/api_response.dart';
import '../../models/event.dart';
import '../../models/event_category.dart';
import '../mock/mock_data.dart';

abstract class EventRepository {
  Future<List<SportEvent>> fetchEvents({String? query, String? categoryId});
  Future<List<SportEvent>> fetchFeaturedEvents();
  Future<EventDetails> fetchEventDetails(String id);
  Future<List<EventCategoryTag>> fetchCategories();
  Future<void> toggleFavorite(String eventId, bool isFavorite);
}

class MockEventRepository implements EventRepository {
  @override
  Future<List<SportEvent>> fetchEvents({String? query, String? categoryId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var results = MockData.events;
    if (categoryId != null && categoryId.isNotEmpty) {
      results = results.where((e) => MockData.eventCategoryIds[e.id]?.contains(categoryId) ?? false).toList();
    }
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results
          .where((e) => e.name.toLowerCase().contains(q) || e.location.city.toLowerCase().contains(q))
          .toList();
    }
    return results;
  }

  @override
  Future<List<SportEvent>> fetchFeaturedEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.events.take(3).toList();
  }

  @override
  Future<EventDetails> fetchEventDetails(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return MockData.eventDetails.firstWhere((e) => e.id == id);
  }

  @override
  Future<List<EventCategoryTag>> fetchCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return MockData.categories;
  }

  @override
  Future<void> toggleFavorite(String eventId, bool isFavorite) async {
    await Future.delayed(const Duration(milliseconds: 150));
  }
}

/// Talks to the existing Laravel/Eventiq REST API. Paths match
/// `AppStrings`/`ApiEndpoints` exactly; only [Env.apiBaseUrl] needs to point
/// at the real feetandpedals.com API host.
class ApiEventRepository implements EventRepository {
  final ApiClient _client = ApiClient.instance;

  // Confirmed live against https://feetandpedals.com/api/events: a standard
  // Laravel paginator directly under `data` (`data.data[]`), matching
  // /api/categories and the reference app's assumption — not the generic
  // docs' `data.events[]` example. The `events` fallback below is dead code
  // kept only in case a future deployment differs.
  List<SportEvent> _parseEventsEnvelope(dynamic data) {
    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      data as Map<String, dynamic>,
      (p0) => p0 as Map<String, dynamic>,
    );
    final raw = response.data ?? const {};
    final events = (raw['data'] as List<dynamic>?) ?? (raw['events'] as List<dynamic>?) ?? const [];
    return events.map((e) => SportEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<SportEvent>> fetchEvents({String? query, String? categoryId}) {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.events, queryParameters: {
        if (query != null && query.isNotEmpty) 'search': query,
        if (categoryId != null && categoryId.isNotEmpty) 'category': categoryId,
      }),
      parse: _parseEventsEnvelope,
    );
  }

  @override
  Future<List<SportEvent>> fetchFeaturedEvents() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.events, queryParameters: {'featured': true}),
      parse: _parseEventsEnvelope,
    );
  }

  @override
  Future<EventDetails> fetchEventDetails(String id) {
    return _client.request(
      (dio) => dio.get('${ApiEndpoints.eventDetails}/$id'),
      parse: (data) {
        final response = ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        );
        // Confirmed live: `data` IS the event object directly, not nested
        // under `data.event` as the generic docs claimed. The `event`
        // fallback below is dead code kept only for safety.
        final raw = response.data ?? const {};
        final eventJson = (raw['id'] != null ? raw : raw['event'] as Map<String, dynamic>?) ?? raw;
        return EventDetails.fromJson(eventJson);
      },
    );
  }

  @override
  Future<List<EventCategoryTag>> fetchCategories() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.categories),
      parse: (data) {
        // Confirmed live against https://feetandpedals.com/api/categories:
        // `data` is a standard Laravel paginator, i.e. the array is at
        // `data.data`, not `data` itself — matches the reference app's
        // assumption, not the generic docs' bare-array example.
        final response = ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        );
        final items = response.data?['data'] as List<dynamic>? ?? const [];
        return items.map((e) => EventCategoryTag.fromJson(e as Map<String, dynamic>)).toList();
      },
    );
  }

  @override
  Future<void> toggleFavorite(String eventId, bool isFavorite) {
    return _client.request(
      (dio) => isFavorite
          ? dio.post(ApiEndpoints.eventFavorite, data: {'event_id': eventId})
          : dio.delete(ApiEndpoints.eventFavorite, data: {'event_id': eventId}),
      parse: (_) {},
    );
  }
}

EventRepository createEventRepository() => Env.useMockData ? MockEventRepository() : ApiEventRepository();
