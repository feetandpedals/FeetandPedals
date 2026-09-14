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
/// The events, categories, ticket types, organizer, and gateway below are
/// **not invented** — they're a live snapshot pulled via `curl` against the
/// real `https://feetandpedals.com/api/...` endpoints (see
/// `docs/eventiq-api-notes.md`), using their real ids so this doubles as a
/// regression fixture once the app is wired to the live API. Only
/// `myTickets` and `notifications` are fabricated, since those need an
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

  /// eventId -> category ids. Live-verified against
  /// GET https://feetandpedals.com/api/event/details/{id} for all 5 events
  /// (some are counter-intuitive but confirmed real, e.g. the walkathon is
  /// tagged Triathlon, not a walking category).
  static final eventCategoryIds = <String, Set<String>>{
    '01m1zp7vgjhyqkmc4apf7m7s2t': {categories[1].id}, // Cycling
    '01m1vw757yyf5vgn9xp6ez16qm': {categories[5].id}, // Triathlon (sic — confirmed live)
    '01m1vvrbn3f0gptv2qxtk4frsf': {categories[2].id, categories[5].id}, // Swimming + Triathlon
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

  // Live-verified against GET https://feetandpedals.com/api/event/details/{id}
  // for all 5 events: organizer (all owned by the same real organizer,
  // "Nisha jain"), ticket_types (one tier per event, named after the
  // category — not multiple price tiers), ticket_max_buy, and real ISO 8601
  // start/end timestamps (the list endpoint's dates were "Sep 30, 2026"
  // style; the details endpoint's are ISO 8601 — both are genuinely real,
  // parseApiDate handles either). `details` below are condensed from the
  // real (much longer) HTML descriptions — the live copy is a WYSIWYG-editor
  // HTML blob with heavy inline styling; see docs/eventiq-api-notes.md.
  static const _organizer = Organizer(id: '01m1vq2cmrp28rsye9ysgy79xk', name: 'Nisha jain');

  static final eventDetails = <EventDetails>[
    EventDetails(
      id: '01m1zp7vgjhyqkmc4apf7m7s2t',
      name: 'HindAyan Cycle Parade, New Delhi',
      details:
          'HindAyan: Ride on for Health, Honour, and Heritage! Inspired by the Tour de '
          "France's finish on the Champs-Élysées, HindAyan's inaugural ride starts from "
          'Kartavya Path (formerly Rajpath) in the heart of New Delhi. India has not won '
          'a single Olympic medal in cycling, and the last Indian cyclist to qualify for '
          'the Olympics was in 1964 — HindAyan was born from a dream to build a cycling '
          'movement that nurtures national talent and celebrates the unity and heritage '
          'of the country.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9f96828b99f-1788843650.jpeg',
      startDate: '2026-09-30T05:01:00.000000Z',
      endDate: '2026-09-30T05:01:00.000000Z',
      ticketMaxBuy: 1999,
      location: const EventLocation(address: 'Chanakyapuri, New Delhi'),
      organizer: _organizer,
      categories: [categories[1]],
      ticketTypes: const [
        EventTicketType(
          id: '52d33692-2b66-45f1-856a-606c0bbd4f63',
          eventId: '01m1zp7vgjhyqkmc4apf7m7s2t',
          name: 'Cycling',
          price: 10,
          totalAvailable: 1998,
        ),
      ],
    ),
    EventDetails(
      id: '01m1vw757yyf5vgn9xp6ez16qm',
      name: 'Chalo Bharat Walkathon Delhi Edition 2027',
      details:
          'Delhi, are you ready to move? The Chalo Bharat Walkathon comes to the capital '
          'on 21st February 2027, bringing together people from all walks of life for a '
          'morning of fitness and fun. Categories: 3K Walk (untimed), 5K Walk (timed), '
          '10K Walk (timed). Participant benefits include an event T-shirt, finisher '
          'medal, vouchers, and breakfast.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da2b579267-1788715701.jpeg',
      startDate: '2027-02-21T17:28:00.000000Z',
      endDate: '2027-02-21T17:28:00.000000Z',
      ticketMaxBuy: 2500,
      location: const EventLocation(address: 'Delhi'),
      organizer: _organizer,
      categories: [categories[5]],
      ticketTypes: const [
        EventTicketType(
          id: 'f8c12267-6d25-4872-8c46-b55aece4143d',
          eventId: '01m1vw757yyf5vgn9xp6ez16qm',
          name: 'Triathlon',
          price: 850,
          totalAvailable: 2500,
        ),
      ],
    ),
    EventDetails(
      id: '01m1vvrbn3f0gptv2qxtk4frsf',
      name: 'CANNONBALL GURUGRAM 2026',
      details:
          "Welcome to CANNONBALL, Gurugram's premier Swimathon — powered by TRI Coaching "
          "India (TCI). Whether you're training for an Ironman 70.3 or just want to see "
          'how far you can go, pick your challenge: 10K, 6K, 4K, 2K, 1K, 500M, or a fun '
          '200M for first-timers. Race Director: Ironman Certified Coach Jatin Arora.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9da3d55dc7c-1788715989.jpeg',
      startDate: '2026-09-27T17:20:00.000000Z',
      endDate: '2026-09-27T17:20:00.000000Z',
      ticketMaxBuy: 250,
      location: const EventLocation(address: 'Olympic Size Pool, CAA, Sector 75A, Gurugram'),
      organizer: _organizer,
      categories: [categories[2], categories[5]],
      ticketTypes: const [
        EventTicketType(
          id: '9caf581c-e79b-495d-b62c-1579c0953c6e',
          eventId: '01m1vvrbn3f0gptv2qxtk4frsf',
          name: 'Swimming',
          price: 999,
          totalAvailable: 249,
        ),
      ],
    ),
    EventDetails(
      id: '01m1vvb33n0b2b7gft4crxp4c2',
      name: 'Almora & Kausani: A Himalayan paradise',
      details:
          'Almora has always kept Himalayan lovers captivated. Located at 5,400 feet, '
          "Almora is the cultural heart of the Kumaon region — home to Kasar Devi Temple, "
          'one of only three places on Earth (alongside Machu Picchu and Stonehenge) with '
          'the strongest geomagnetic field, believed ideal for meditation. Along with '
          'Almora, the trip visits Kausani, Binsar, and Bhimtal across 6 days.',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9f1dc552f-1788714781.jpeg',
      startDate: '2026-10-01T17:13:00.000000Z',
      endDate: '2026-10-06T17:13:00.000000Z',
      ticketMaxBuy: 150,
      location: const EventLocation(address: 'Delhi'),
      organizer: _organizer,
      categories: [categories[4]],
      ticketTypes: const [
        EventTicketType(
          id: '9ea48600-05d5-4c16-917f-98251de360e8',
          eventId: '01m1vvb33n0b2b7gft4crxp4c2',
          name: 'Trekking',
          price: 29000,
          totalAvailable: 150,
        ),
      ],
    ),
    EventDetails(
      id: '01m1vtd0cz2nksaamjvm6kbj4x',
      name: 'HARVEST GOLD GLOBAL RACE 2026',
      details:
          'Fuel the Run. Nourish the World. Grupo Bimbo, the world\'s largest bakery '
          "company, presents the 11th edition of its 'Race with a Cause' — the Harvest "
          'Gold Global Race — on 20th September 2026 in Gurugram. For every registration, '
          '20 slices of bread are donated to those in need. Categories: 10K (₹1,500), 5K '
          '(₹1,200), 3K (₹900), and a 3K Walkathon (₹900).',
      imageUrl: 'https://feetandpedals.com/images/event_banner/6a9d9fee2a5fc-1788714990.jpeg',
      startDate: '2026-09-20T16:56:00.000000Z',
      endDate: '2026-09-20T16:56:00.000000Z',
      ticketMaxBuy: 1000,
      location: const EventLocation(address: 'DLF cyber city gurugram'),
      organizer: _organizer,
      categories: [categories[0]],
      ticketTypes: const [
        EventTicketType(
          id: '7dd4bee6-d431-4e02-85f1-696b10c3adda',
          eventId: '01m1vtd0cz2nksaamjvm6kbj4x',
          name: 'Running',
          price: 720,
          totalAvailable: 998,
        ),
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
