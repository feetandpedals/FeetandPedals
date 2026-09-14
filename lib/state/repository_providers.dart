import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/auth_repository.dart';
import '../data/repositories/checkout_repository.dart';
import '../data/repositories/event_repository.dart';
import '../data/repositories/notification_repository.dart';
import '../data/repositories/ticket_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => createAuthRepository());
final eventRepositoryProvider = Provider<EventRepository>((ref) => createEventRepository());
final ticketRepositoryProvider = Provider<TicketRepository>((ref) => createTicketRepository());
final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) => createCheckoutRepository());
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) => createNotificationRepository());
