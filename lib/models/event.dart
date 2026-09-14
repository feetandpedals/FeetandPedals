import '../core/utils/formatters.dart';
import 'event_category.dart';
import 'event_ticket_type.dart';
import 'location.dart';
import 'organizer.dart';

/// Summary shape returned by `GET /events` (list/search results).
/// Mirrors Eventiq's `Event` model field-for-field.
class SportEvent {
  final String id;
  final String name;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final String startingPrice;
  final bool isFavorite;
  final EventLocation location;

  const SportEvent({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.startDate = '',
    this.endDate = '',
    this.startingPrice = '0',
    this.isFavorite = false,
    this.location = const EventLocation(),
  });

  // Live-verified against GET /api/events: start_date/end_date come back as
  // "Sep 30, 2026" (MMM d, yyyy), not ISO 8601 — parseApiDate handles both.
  DateTime? get startDateTime => parseApiDate(startDate);
  double get startingPriceValue => double.tryParse(startingPrice) ?? 0;
  bool get isFree => startingPriceValue == 0;

  factory SportEvent.fromJson(Map<String, dynamic> json) {
    return SportEvent(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['banner'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      startingPrice: (json['starting_price'] ?? '0').toString(),
      isFavorite: json['is_favorite'] == true,
      location: EventLocation.fromJson(json['location'] as Map<String, dynamic>?),
    );
  }
}

/// Full shape returned by `GET /event/details/{id}`. Only the subset of
/// Eventiq's much larger `EventDetails` payload that the MVP1 UI needs is
/// modeled here — every `fromJson` is tolerant of the extra fields the real
/// API returns.
class EventDetails {
  final String id;
  final String name;
  final String details;
  final String imageUrl;
  final String startDate;
  final String endDate;
  final bool isFavorite;
  final bool isFree;
  final int ticketMaxBuy;
  final String ticketPurchaseLastDate;
  final EventLocation location;
  final Organizer organizer;
  final List<EventCategoryTag> categories;
  final List<EventTicketType> ticketTypes;
  final num averageRating;
  final int totalReviews;

  const EventDetails({
    required this.id,
    required this.name,
    this.details = '',
    this.imageUrl = '',
    this.startDate = '',
    this.endDate = '',
    this.isFavorite = false,
    this.isFree = false,
    this.ticketMaxBuy = 10,
    this.ticketPurchaseLastDate = '',
    this.location = const EventLocation(),
    this.organizer = const Organizer(),
    this.categories = const [],
    this.ticketTypes = const [],
    this.averageRating = 0,
    this.totalReviews = 0,
  });

  DateTime? get startDateTime => parseApiDate(startDate);
  DateTime? get endDateTime => parseApiDate(endDate);

  double get lowestPrice {
    if (ticketTypes.isEmpty) return 0;
    return ticketTypes.map((t) => t.discountedPrice).reduce((a, b) => a < b ? a : b);
  }

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      details: (json['details'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? json['banner'] ?? '').toString(),
      startDate: (json['start_date'] ?? '').toString(),
      endDate: (json['end_date'] ?? '').toString(),
      // Field name differs between the Eventiq reference app (`is_favorite`)
      // and the documented API (`is_favorited`) — accept either.
      isFavorite: json['is_favorite'] == true || json['is_favorited'] == true,
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      ticketMaxBuy: int.tryParse((json['ticket_max_buy'] ?? 10).toString()) ?? 10,
      ticketPurchaseLastDate: (json['ticket_purchase_last_date'] ?? '').toString(),
      // Some deployments return a nested `locations`/`location` object
      // (city/state/country/address); the documented API instead returns a
      // single flat `address` string — support both.
      location: json['locations'] != null || json['location'] != null
          ? EventLocation.fromJson(
              json['locations'] as Map<String, dynamic>? ?? json['location'] as Map<String, dynamic>?)
          : EventLocation(address: (json['address'] ?? '').toString()),
      organizer: Organizer.fromJson(json['organizer'] as Map<String, dynamic>?),
      categories: (json['categories'] as List<dynamic>? ?? const [])
          .map((e) => EventCategoryTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      ticketTypes: (json['ticket_types'] as List<dynamic>? ?? const [])
          .map((e) => EventTicketType.fromJson(e as Map<String, dynamic>))
          .toList(),
      // Falls back to the organizer's rating when the event itself has no
      // aggregate rating field (the documented API only shows rating on
      // `organizer.average_rating`; `reviews` is a raw list with no count).
      averageRating: (json['average_rating'] as num?) ??
          (num.tryParse((json['organizer']?['average_rating'] ?? '').toString())) ??
          0,
      totalReviews: (json['total_reviews'] as int?) ?? (json['reviews'] as List<dynamic>?)?.length ?? 0,
    );
  }
}
