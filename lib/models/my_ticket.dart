import '../core/utils/formatters.dart';

/// A purchased/registered ticket, as returned by `GET /my-tickets`. Matches
/// Eventiq's `Ticket` model in `models/ticket/ticket.dart`.
class MyTicket {
  final String purchaseId;
  final String trx;
  final String eventId;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventLocation;
  final String eventImage;
  final int totalTickets;
  final String status; // pending | completed | cancelled
  final String qrCode;
  final String attendeeName;
  final String categoryName;

  const MyTicket({
    required this.purchaseId,
    this.trx = '',
    this.eventId = '',
    this.eventName = '',
    this.eventDate = '',
    this.eventTime = '',
    this.eventLocation = '',
    this.eventImage = '',
    this.totalTickets = 1,
    this.status = 'completed',
    this.qrCode = '',
    this.attendeeName = '',
    this.categoryName = '',
  });

  // /api/events confirmed dates come back as "MMM d, yyyy", not ISO 8601 —
  // /my-tickets is unverified but very likely shares the same formatting.
  DateTime? get eventDateTime => parseApiDate(eventDate) ?? parseApiDate('$eventDate $eventTime'.trim());
  bool get isUpcoming {
    final d = parseApiDate(eventDate);
    if (d == null) return true;
    return d.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  factory MyTicket.fromJson(Map<String, dynamic> json) {
    return MyTicket(
      purchaseId: (json['purchase_id'] ?? '').toString(),
      trx: (json['trx'] ?? '').toString(),
      eventId: (json['event_id'] ?? '').toString(),
      eventName: (json['event_name'] ?? '').toString(),
      eventDate: (json['event_date'] ?? '').toString(),
      eventTime: (json['event_time'] ?? '').toString(),
      eventLocation: (json['event_location'] ?? '').toString(),
      eventImage: (json['event_image'] ?? '').toString(),
      totalTickets: (json['total_tickets'] as int?) ?? 1,
      status: (json['status'] ?? 'completed').toString(),
      qrCode: (json['qr_code'] ?? json['trx'] ?? '').toString(),
      attendeeName: (json['attendee_name'] ?? '').toString(),
      categoryName: (json['category_name'] ?? '').toString(),
    );
  }
}
