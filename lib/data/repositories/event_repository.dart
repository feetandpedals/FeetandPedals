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

  // The documented envelope nests the array under `data.events` (plus
  // `data.pagination`/`data.filters`), not a bare Laravel paginator under
  // `data` — see developer-api-architecture.html, GET /api/events.
  List<SportEvent> _parseEventsEnvelope(dynamic data) {
    final response = ApiResponse<Map<String, dynamic>>.fromJson(
      data as Map<String, dynamic>,
      (p0) => p0 as Map<String, dynamic>,
    );
    final events = response.data?['events'] as List<dynamic>? ?? const [];
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
        // The event is nested under `data.event`, per the documented shape.
        final eventJson = response.data?['event'] as Map<String, dynamic>? ?? response.data ?? const {};
        return EventDetails.fromJson(eventJson);
      },
    );
  }

  @override
  Future<List<EventCategoryTag>> fetchCategories() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.categories),
      parse: (data) {
        final response = ApiResponse<List<dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as List<dynamic>,
        );
        return (response.data ?? const [])
            .map((e) => EventCategoryTag.fromJson(e as Map<String, dynamic>))
            .toList();
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
