import '../../models/app_notification.dart';
import '../../models/event.dart';
import '../../models/event_category.dart';
import '../../models/event_ticket_type.dart';
import '../../models/location.dart';
import '../../models/my_ticket.dart';
import '../../models/organizer.dart';

/// Placeholder demo catalog (India / INR) used only while
/// `Env.useMockData` is true — i.e. before the app is pointed at the real
/// feetandpedals.com API. Every shape here matches the real Eventiq REST
/// contract so swapping to [ApiEventRepository] requires no UI changes.
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
  static final eventCategoryIds = <String, Set<String>>{
    'evt-1': {categories[1].id}, // Cycling
    'evt-2': {categories[0].id}, // Running
    'evt-3': {categories[5].id}, // Triathlon
    'evt-4': {categories[6].id, categories[0].id}, // Trail running / Ultra + Running
    'evt-5': {categories[1].id, categories[7].id}, // Cycling + Nature Walks
  };

  static final DateTime _now = DateTime.now();

  static final events = <SportEvent>[
    SportEvent(
      id: 'evt-1',
      name: 'Ladakh Himalayan Cycling Challenge',
      imageUrl: 'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=800',
      startDate: _now.add(const Duration(days: 28)).toIso8601String(),
      endDate: _now.add(const Duration(days: 29)).toIso8601String(),
      startingPrice: '3500',
      location: const EventLocation(city: 'Leh', state: 'Ladakh', country: 'India'),
    ),
    SportEvent(
      id: 'evt-2',
      name: 'Mumbai Coastal Marathon',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      startDate: _now.add(const Duration(days: 14)).toIso8601String(),
      startingPrice: '900',
      location: const EventLocation(city: 'Mumbai', state: 'Maharashtra', country: 'India'),
    ),
    SportEvent(
      id: 'evt-3',
      name: 'Goa Beach Duathlon',
      imageUrl: 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=800',
      startDate: _now.add(const Duration(days: 45)).toIso8601String(),
      startingPrice: '2200',
      location: const EventLocation(city: 'Candolim', state: 'Goa', country: 'India'),
    ),
    SportEvent(
      id: 'evt-4',
      name: 'Bengaluru Trail Run',
      imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
      startDate: _now.add(const Duration(days: 7)).toIso8601String(),
      startingPrice: '600',
      location: const EventLocation(city: 'Bengaluru', state: 'Karnataka', country: 'India'),
    ),
    SportEvent(
      id: 'evt-5',
      name: 'Delhi Heritage Family Ride',
      imageUrl: 'https://images.unsplash.com/photo-1471506480208-91b3a4cc78be?w=800',
      startDate: _now.add(const Duration(days: 21)).toIso8601String(),
      startingPrice: '0',
      location: const EventLocation(city: 'New Delhi', state: 'Delhi', country: 'India'),
    ),
  ];

  static final eventDetails = <EventDetails>[
    EventDetails(
      id: 'evt-1',
      name: 'Ladakh Himalayan Cycling Challenge',
      details:
          'Ride through some of the highest motorable passes in the world. Choose '
          'between the 100km and 160km routes across breathtaking Himalayan '
          'landscapes. Includes support vehicles, hydration stops, oxygen support '
          'at altitude, and a finisher medal.',
      imageUrl: 'https://images.unsplash.com/photo-1541625602330-2277a4c46182?w=1200',
      startDate: _now.add(const Duration(days: 28, hours: 6)).toIso8601String(),
      endDate: _now.add(const Duration(days: 29, hours: 14)).toIso8601String(),
      ticketPurchaseLastDate: _now.add(const Duration(days: 25)).toIso8601String(),
      location: const EventLocation(
        city: 'Leh',
        state: 'Ladakh',
        country: 'India',
        address: 'Leh Palace Grounds',
      ),
      organizer: const Organizer(id: 'org-1', name: 'Himalayan Cycling Club'),
      categories: const [EventCategoryTag(id: 'cat-cycling', name: 'Cycling')],
      averageRating: 4.7,
      totalReviews: 128,
      ticketTypes: [
        EventTicketType(id: 'tt-1a', eventId: 'evt-1', name: '100km Road Ride', price: 3500),
        EventTicketType(id: 'tt-1b', eventId: 'evt-1', name: '160km Road Ride', price: 4800),
      ],
    ),
    EventDetails(
      id: 'evt-2',
      name: 'Mumbai Coastal Marathon',
      details:
          'A flat, fast course tracing Mumbai\'s coastline with 5K, 10K, and 21K '
          'distances. Chip timing, finisher medal, hydration every 2.5km, and a '
          'post-race breakfast for all finishers.',
      imageUrl: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=1200',
      startDate: _now.add(const Duration(days: 14, hours: 5)).toIso8601String(),
      ticketPurchaseLastDate: _now.add(const Duration(days: 12)).toIso8601String(),
      location: const EventLocation(
        city: 'Mumbai',
        state: 'Maharashtra',
        country: 'India',
        address: 'Marine Drive',
      ),
      organizer: const Organizer(id: 'org-2', name: 'Feet and Pedals Events'),
      categories: const [EventCategoryTag(id: 'cat-running', name: 'Running')],
      averageRating: 4.5,
      totalReviews: 340,
      ticketTypes: [
        EventTicketType(id: 'tt-2a', eventId: 'evt-2', name: '5K Fun Run', price: 900),
        EventTicketType(id: 'tt-2b', eventId: 'evt-2', name: '10K', price: 1400),
        EventTicketType(id: 'tt-2c', eventId: 'evt-2', name: '21K Half Marathon', price: 2200),
      ],
    ),
    EventDetails(
      id: 'evt-3',
      name: 'Goa Beach Duathlon',
      details:
          'A beginner-friendly duathlon: 5km beach run, 20km coastal bike leg, '
          '2.5km beach run. Relay teams welcome. Bike racking and gear check '
          'available from 5:30am.',
      imageUrl: 'https://images.unsplash.com/photo-1519861531473-9200262188bf?w=1200',
      startDate: _now.add(const Duration(days: 45, hours: 6)).toIso8601String(),
      ticketPurchaseLastDate: _now.add(const Duration(days: 40)).toIso8601String(),
      location: const EventLocation(
        city: 'Candolim',
        state: 'Goa',
        country: 'India',
        address: 'Candolim Beach',
      ),
      organizer: const Organizer(id: 'org-3', name: 'Goa Multisport Club'),
      categories: const [EventCategoryTag(id: 'cat-triathlon', name: 'Triathlon')],
      averageRating: 4.6,
      totalReviews: 76,
      ticketTypes: [
        EventTicketType(id: 'tt-3a', eventId: 'evt-3', name: 'Individual', price: 2200),
        EventTicketType(id: 'tt-3b', eventId: 'evt-3', name: 'Relay Team (2 members)', price: 3800),
      ],
    ),
    EventDetails(
      id: 'evt-4',
      name: 'Bengaluru Trail Run',
      details:
          'A scenic 12km/21km trail run through the forests on the outskirts of '
          'Bengaluru. Single-track trails, stream crossings, and a well-marked '
          'course with cut-off times.',
      imageUrl: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=1200',
      startDate: _now.add(const Duration(days: 7, hours: 5, minutes: 30)).toIso8601String(),
      ticketPurchaseLastDate: _now.add(const Duration(days: 5)).toIso8601String(),
      location: const EventLocation(
        city: 'Bengaluru',
        state: 'Karnataka',
        country: 'India',
        address: 'Nandi Hills Foothills',
      ),
      organizer: const Organizer(id: 'org-4', name: 'Trail Runners Karnataka'),
      categories: const [
        EventCategoryTag(id: 'cat-trail', name: 'Trail'),
        EventCategoryTag(id: 'cat-running', name: 'Running'),
      ],
      averageRating: 4.8,
      totalReviews: 54,
      ticketTypes: [
        EventTicketType(id: 'tt-4a', eventId: 'evt-4', name: '12km Trail', price: 600),
        EventTicketType(id: 'tt-4b', eventId: 'evt-4', name: '21km Trail', price: 950),
      ],
    ),
    EventDetails(
      id: 'evt-5',
      name: 'Delhi Heritage Family Ride',
      details:
          'A relaxed, family-friendly 10km cycling tour past Delhi\'s most iconic '
          'monuments. Suitable for all ages and skill levels. Helmets and support '
          'vehicles provided.',
      imageUrl: 'https://images.unsplash.com/photo-1471506480208-91b3a4cc78be?w=1200',
      startDate: _now.add(const Duration(days: 21, hours: 6)).toIso8601String(),
      ticketPurchaseLastDate: _now.add(const Duration(days: 19)).toIso8601String(),
      isFree: true,
      location: const EventLocation(
        city: 'New Delhi',
        state: 'Delhi',
        country: 'India',
        address: 'India Gate',
      ),
      organizer: const Organizer(id: 'org-5', name: 'Feet and Pedals Events'),
      categories: const [
        EventCategoryTag(id: 'cat-cycling', name: 'Cycling'),
        EventCategoryTag(id: 'cat-walking', name: 'Walking'),
      ],
      averageRating: 4.9,
      totalReviews: 21,
      ticketTypes: [
        EventTicketType(id: 'tt-5a', eventId: 'evt-5', name: 'Adult Entry', price: 0, isFree: true),
        EventTicketType(id: 'tt-5b', eventId: 'evt-5', name: 'Child Entry (under 12)', price: 0, isFree: true),
      ],
    ),
  ];

  static final myTickets = <MyTicket>[
    MyTicket(
      purchaseId: 'PUR1001',
      trx: 'FP202510120001',
      eventId: 'evt-2',
      eventName: 'Mumbai Coastal Marathon',
      eventDate: _now.add(const Duration(days: 14)).toIso8601String().split('T').first,
      eventTime: '05:00',
      eventLocation: 'Marine Drive, Mumbai',
      eventImage: 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=800',
      totalTickets: 1,
      status: 'completed',
      attendeeName: 'Alex Tan',
      categoryName: '10K',
    ),
    MyTicket(
      purchaseId: 'PUR1002',
      trx: 'FP202409080002',
      eventId: 'evt-4',
      eventName: 'Bengaluru Trail Run',
      eventDate: _now.subtract(const Duration(days: 40)).toIso8601String().split('T').first,
      eventTime: '05:30',
      eventLocation: 'Nandi Hills Foothills, Bengaluru',
      eventImage: 'https://images.unsplash.com/photo-1517649763962-0c623066013b?w=800',
      totalTickets: 1,
      status: 'completed',
      attendeeName: 'Alex Tan',
      categoryName: '12km Trail',
    ),
  ];

  static final notifications = <AppNotification>[
    AppNotification(
      id: 'n1',
      title: 'Registration Confirmed',
      body: 'Your registration for Mumbai Coastal Marathon is confirmed.',
      kind: NotificationKind.registration,
      createdAt: _now.subtract(const Duration(minutes: 2)),
      isRead: false,
    ),
    AppNotification(
      id: 'n2',
      title: 'New Event Announcement',
      body: 'Ladakh Himalayan Cycling Challenge registrations are now open.',
      kind: NotificationKind.event,
      createdAt: _now.subtract(const Duration(hours: 1)),
      isRead: false,
    ),
    AppNotification(
      id: 'n3',
      title: 'Payment Successful',
      body: 'Your payment of ₹1,400 for 10K was successful.',
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
