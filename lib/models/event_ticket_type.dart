/// A purchasable ticket/category tier for an event (Eventiq's `Ticket`
/// model nested under event details, e.g. "Running", "Cycling" — live data
/// shows these named after the event's category, one tier per event so far,
/// rather than distinct price tiers like "Early Bird"/"VIP").
class EventTicketType {
  final String id;
  final String eventId;
  final String name;
  final double price;
  final bool isFree;
  final bool hasDiscount;
  final double discountValue;
  final String discountType; // 'percentage' | 'fixed'

  /// Total inventory for this ticket type (Eventiq's `number_of_tickets`).
  /// This is NOT a per-order purchase limit — that's [EventDetails.ticketMaxBuy]
  /// at the event level (confirmed live: `number_of_tickets` was 150–2500,
  /// clearly total capacity, not a sane per-order cap).
  final int totalAvailable;

  const EventTicketType({
    required this.id,
    required this.eventId,
    required this.name,
    required this.price,
    this.isFree = false,
    this.hasDiscount = false,
    this.discountValue = 0,
    this.discountType = 'fixed',
    this.totalAvailable = 0,
  });

  double get discountedPrice {
    if (!hasDiscount) return price;
    if (discountType == 'percentage') {
      return (price - (price * discountValue / 100)).clamp(0, price);
    }
    return (price - discountValue).clamp(0, price);
  }

  factory EventTicketType.fromJson(Map<String, dynamic> json) {
    return EventTicketType(
      id: (json['id'] ?? '').toString(),
      eventId: (json['event_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      price: double.tryParse((json['price'] ?? '0').toString()) ?? 0,
      isFree: json['is_free'] == 1 || json['is_free'] == true,
      hasDiscount: json['have_discount'] == 1 || json['have_discount'] == true,
      discountValue: double.tryParse((json['discount_value'] ?? '0').toString()) ?? 0,
      discountType: (json['discount_type'] ?? 'fixed').toString(),
      totalAvailable: int.tryParse((json['number_of_tickets'] ?? 0).toString()) ?? 0,
    );
  }
}
