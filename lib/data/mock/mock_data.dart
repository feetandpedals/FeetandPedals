import '../../models/app_notification.dart';
import '../../models/event.dart';
import '../../models/event_category.dart';
import '../../models/event_ticket_type.dart';
import '../../models/location.dart';
import '../../models/my_ticket.dart';
import '../../models/organizer.dart';

/// Demo catalog used only while `Env.useMockData` is true — i.e. before the
/// app is pointed at the real feetandpedals.com API (`--dart-define=USE_MOCK_DATA=false`).
///
/// The events, categories, and gateway below are **not invented** — they're
/// a live snapshot pulled via `curl` against the real
/// `https://feetandpedals.com/api/...` endpoints (see
/// `docs/eventiq-api-notes.md`), using their real ids so this doubles as a
/// regression fixture once the app is wired to the live API. Only
/// `ticketTypes` (no live breakdown was available, just `starting_price`),
/// `myTickets`, and `notifications` are fabricated, since those need an
/// authenticated account to observe live.
class MockData {
  MockData._();

  // Real category ids/names confirmed live from
  // GET https://feetandpedals.com/api/categories.
  static const categories = [
    EventCategoryTag(id: '01m1trjt5hynp49stv3j94wpx1', name: 'Running'),
    EventCategoryTag(id: '01m1trkqtaf1cmkkdrx8jfn2xv', name: 'Cycling'),
    EventCategoryTag(id: '01m1trv0najxjngqd1g7wktf30', name: 'Swimming'),
    EventCategoryTag(id: '01m1trvpzmk4vcz3kn5ar6mf3v', name: 'Hiking'),
    EventCategoryTag(id: '01m1trwf2azp43t1gymcn4x5sm', name: 'Trekking'),
    EventCategoryTag(id: '01m1trx6k676jm9xvkx71ytaxb', name: 'Triathlon'),
    EventCategoryTag(id: '01m1try02wph62qrmqhvqhv1ce', name: 'Trail running / Ultra'),
    EventCategoryTag(id: '01m1tryh0rcqav1an5h3g582s5', name: 'Nature Walks'),
    EventCategoryTag(id: '01m1trz22jfdp1zkm48qw0jrk3', name: 'Duathlon'),
    EventCategoryTag(id: '01m1trzmv9jbtcazwedfpj8vr6', name: 'Swimathon'),
  ];

  /// eventId -> category ids, used only by the mock repository's filter.
  /// The real API responses didn't include a category on each event, so
  /// these are a best-effort guess from each event's name/venue.
  static final eventCategoryIds = <String, Set<String>>{
    '01m1zp7vgjhyqkmc4apf7m7s2t': {categories[1].id}, // Cycling
    '01m1vw757yyf5vgn9xp6ez16qm': {categories[7].id}, // Nature Walks
    '01m1vvrbn3f0gptv2qxtk4frsf': {categories[9].id}, // Swimathon
    '01m1vvb33n0b2b7gft4crxp4c2': {categories[4].id}, // Trekking
    '01m1vtd0cz2nksaamjvm6kbj4x': {categories[0].id}, // Running
  };

  static final DateTime _now = DateTime.now();

  // Live-verified via GET https://feetandpedals.com/api/events.
  static final events = <SportEvent>[
    const SportEvent(
      id: '01m1zp7vgjhyqkmc4apf7m7s2t',
      name: 'HindAyan Cycle Parade, New Delhi',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9f96828b99f-1788843650.jpeg',
      startDate: 'Sep 30, 2026',
      endDate: 'Sep 30, 2026',
      startingPrice: '10.00',
      location: EventLocation(address: 'Chanakyapuri, New Delhi'),
    ),
    const SportEvent(
      id: '01m1vw757yyf5vgn9xp6ez16qm',
      name: 'Chalo Bharat Walkathon Delhi Edition 2027',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da2b579267-1788715701.jpeg',
      startDate: 'Feb 21, 2027',
      endDate: 'Feb 21, 2027',
      startingPrice: '850.00',
      location: EventLocation(address: 'Delhi'),
    ),
    const SportEvent(
      id: '01m1vvrbn3f0gptv2qxtk4frsf',
      name: 'CANNONBALL GURUGRAM 2026',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da3d55dc7c-1788715989.jpeg',
      startDate: 'Sep 27, 2026',
      endDate: 'Sep 27, 2026',
      startingPrice: '999.00',
      location: EventLocation(address: 'Olympic Size Pool, CAA, Sector 75A, Gurugram'),
    ),
    const SportEvent(
      id: '01m1vvb33n0b2b7gft4crxp4c2',
      name: 'Almora & Kausani: A Himalayan paradise',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9f1dc552f-1788714781.jpeg',
      startDate: 'Oct 01, 2026',
      endDate: 'Oct 06, 2026',
      startingPrice: '29000.00',
      location: EventLocation(address: 'Delhi'),
    ),
    const SportEvent(
      id: '01m1vtd0cz2nksaamjvm6kbj4x',
      name: 'HARVEST GOLD GLOBAL RACE 2026',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9fee2a5fc-1788714990.jpeg',
      startDate: 'Sep 20, 2026',
      endDate: 'Sep 20, 2026',
      startingPrice: '720.00',
      location: EventLocation(address: 'DLF cyber city gurugram'),
    ),
  ];

  // Ticket type breakdowns below are estimates seeded from each event's
  // real `starting_price` — the live /api/events response doesn't include
  // the per-category ticket list, and /api/event/details/{id} wasn't
  // confirmed live yet (see docs/eventiq-api-notes.md). Replace with real
  // ticket_types once that endpoint is confirmed.
  static final eventDetails = <EventDetails>[
    EventDetails(
      id: '01m1zp7vgjhyqkmc4apf7m7s2t',
      name: 'HindAyan Cycle Parade, New Delhi',
      details:
          'A community cycle parade through the diplomatic enclave of Chanakyapuri. '
          'A relaxed, family-friendly ride open to all ages and cycle types.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9f96828b99f-1788843650.jpeg',
      startDate: 'Sep 30, 2026',
      endDate: 'Sep 30, 2026',
      location: const EventLocation(address: 'Chanakyapuri, New Delhi'),
      organizer: const Organizer(name: 'Feet and Pedals Events'),
      categories: [categories[1]],
      ticketTypes: const [
        EventTicketType(id: 'tt-1a', eventId: '01m1zp7vgjhyqkmc4apf7m7s2t', name: 'General Entry', price: 10),
      ],
    ),
    EventDetails(
      id: '01m1vw757yyf5vgn9xp6ez16qm',
      name: 'Chalo Bharat Walkathon Delhi Edition 2027',
      details:
          'A citywide walkathon supporting community fitness initiatives across Delhi. '
          'Timed and untimed categories available.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da2b579267-1788715701.jpeg',
      startDate: 'Feb 21, 2027',
      endDate: 'Feb 21, 2027',
      location: const EventLocation(address: 'Delhi'),
      organizer: const Organizer(name: 'Feet and Pedals Events'),
      categories: [categories[7]],
      ticketTypes: const [
        EventTicketType(id: 'tt-2a', eventId: '01m1vw757yyf5vgn9xp6ez16qm', name: 'Standard Entry', price: 850),
      ],
    ),
    EventDetails(
      id: '01m1vvrbn3f0gptv2qxtk4frsf',
      name: 'CANNONBALL GURUGRAM 2026',
      details:
          'A high-energy swim event at the Olympic Size Pool, CAA, Sector 75A, Gurugram. '
          'Multiple distance categories for swimmers of all levels.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da3d55dc7c-1788715989.jpeg',
      startDate: 'Sep 27, 2026',
      endDate: 'Sep 27, 2026',
      location: const EventLocation(address: 'Olympic Size Pool, CAA, Sector 75A, Gurugram'),
      organizer: const Organizer(name: 'Feet and Pedals Events'),
      categories: [categories[9]],
      ticketTypes: const [
        EventTicketType(id: 'tt-3a', eventId: '01m1vvrbn3f0gptv2qxtk4frsf', name: 'General Entry', price: 999),
      ],
    ),
    EventDetails(
      id: '01m1vvb33n0b2b7gft4crxp4c2',
      name: 'Almora & Kausani: A Himalayan paradise',
      details:
          'A multi-day trekking expedition through the Himalayan towns of Almora and '
          'Kausani. Includes guided treks, stays, and meals across 6 days.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9f1dc552f-1788714781.jpeg',
      startDate: 'Oct 01, 2026',
      endDate: 'Oct 06, 2026',
      location: const EventLocation(address: 'Delhi'),
      organizer: const Organizer(name: 'Feet and Pedals Events'),
      categories: [categories[4]],
      ticketTypes: const [
        EventTicketType(
            id: 'tt-4a', eventId: '01m1vvb33n0b2b7gft4crxp4c2', name: '6-Day Expedition Package', price: 29000),
      ],
    ),
    EventDetails(
      id: '01m1vtd0cz2nksaamjvm6kbj4x',
      name: 'HARVEST GOLD GLOBAL RACE 2026',
      details:
          'A global race event at DLF Cyber City, Gurugram, with multiple distance '
          'categories through the business district.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9fee2a5fc-1788714990.jpeg',
      startDate: 'Sep 20, 2026',
      endDate: 'Sep 20, 2026',
      location: const EventLocation(address: 'DLF cyber city gurugram'),
      organizer: const Organizer(name: 'Feet and Pedals Events'),
      categories: [categories[0]],
      ticketTypes: const [
        EventTicketType(id: 'tt-5a', eventId: '01m1vtd0cz2nksaamjvm6kbj4x', name: '10K', price: 720),
        EventTicketType(id: 'tt-5b', eventId: '01m1vtd0cz2nksaamjvm6kbj4x', name: '5K', price: 500),
      ],
    ),
  ];

  static final myTickets = <MyTicket>[
    MyTicket(
      purchaseId: 'PUR1001',
      trx: 'FP202510120001',
      eventId: '01m1vtd0cz2nksaamjvm6kbj4x',
      eventName: 'HARVEST GOLD GLOBAL RACE 2026',
      eventDate: 'Sep 20, 2026',
      eventTime: '05:00',
      eventLocation: 'DLF cyber city gurugram',
      eventImage: 'https://feetandpedals.com/images/event_banner/6a9d9fee2a5fc-1788714990.jpeg',
      totalTickets: 1,
      status: 'completed',
      attendeeName: 'Alex Tan',
      categoryName: '10K',
    ),
    MyTicket(
      purchaseId: 'PUR1002',
      trx: 'FP202409080002',
      eventId: '01m1zp7vgjhyqkmc4apf7m7s2t',
      eventName: 'HindAyan Cycle Parade, New Delhi',
      eventDate: _now.subtract(const Duration(days: 40)).toIso8601String().split('T').first,
      eventTime: '06:30',
      eventLocation: 'Chanakyapuri, New Delhi',
      eventImage: 'https://feetandpedals.com/images/event_banner/6a9f96828b99f-1788843650.jpeg',
      totalTickets: 1,
      status: 'completed',
      attendeeName: 'Alex Tan',
      categoryName: 'General Entry',
    ),
  ];

  static final notifications = <AppNotification>[
    AppNotification(
      id: 'n1',
      title: 'Registration Confirmed',
      body: 'Your registration for HARVEST GOLD GLOBAL RACE 2026 is confirmed.',
      kind: NotificationKind.registration,
      createdAt: _now.subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'New Event Announcement',
      body: 'Almora & Kausani: A Himalayan paradise registrations are now open.',
      kind: NotificationKind.event,
      createdAt: _now.subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AppNotification(
      id: 'n3',
      title: 'Payment Successful',
      body: 'Your payment of ₹720 for 10K was successful.',
      kind: NotificationKind.payment,
      createdAt: _now.subtract(const Duration(hours: 6)),
      isRead: true,
    ),
    AppNotification(
      id: 'n4',
      title: 'Special Offer',
      body: 'Get 10% off early-bird registration this week.',
      kind: NotificationKind.promotion,
      createdAt: _now.subtract(const Duration(days: 2)),
      isRead: true,
    ),
    AppNotification(
      id: 'n5',
      title: 'Welcome to Feet and Pedals!',
      body: 'Thanks for joining our community.',
      kind: NotificationKind.general,
      createdAt: _now.subtract(const Duration(days: 3)),
      isRead: true,
    ),
  ];
}
