import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/my_ticket.dart';
import 'repository_providers.dart';

final myTicketsProvider = FutureProvider.autoDispose<List<MyTicket>>((ref) {
  return ref.watch(ticketRepositoryProvider).fetchMyTickets();
});

final upcomingTicketsProvider = FutureProvider.autoDispose<List<MyTicket>>((ref) async {
  final tickets = await ref.watch(myTicketsProvider.future);
  final upcoming = tickets.where((t) => t.isUpcoming).toList()
    ..sort((a, b) => (a.eventDateTime ?? DateTime.now()).compareTo(b.eventDateTime ?? DateTime.now()));
  return upcoming;
});

final pastTicketsProvider = FutureProvider.autoDispose<List<MyTicket>>((ref) async {
  final tickets = await ref.watch(myTicketsProvider.future);
  final past = tickets.where((t) => !t.isUpcoming).toList()
    ..sort((a, b) => (b.eventDateTime ?? DateTime.now()).compareTo(a.eventDateTime ?? DateTime.now()));
  return past;
});
