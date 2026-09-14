import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/my_ticket.dart';
import '../../state/tickets_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/network_image_box.dart';

class MyTicketsScreen extends ConsumerStatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  ConsumerState<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _MyTicketsScreenState extends ConsumerState<MyTicketsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Tickets'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Upcoming'), Tab(text: 'Past')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_TicketList(isUpcoming: true), _TicketList(isUpcoming: false)],
      ),
    );
  }
}

class _TicketList extends ConsumerWidget {
  final bool isUpcoming;
  const _TicketList({required this.isUpcoming});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(isUpcoming ? upcomingTicketsProvider : pastTicketsProvider);

    return ticketsAsync.when(
      data: (tickets) {
        if (tickets.isEmpty) {
          return EmptyStateView(
            icon: Icons.confirmation_number_outlined,
            title: isUpcoming ? 'No upcoming tickets' : 'No past tickets',
            message: isUpcoming ? 'Register for an event to see your ticket here.' : 'Tickets from past events will appear here.',
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(myTicketsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _TicketCard(ticket: tickets[index]),
          ),
        );
      },
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(message: 'Could not load your tickets.', onRetry: () => ref.invalidate(myTicketsProvider)),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final MyTicket ticket;
  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/tickets/${ticket.purchaseId}'),
        child: Row(
          children: [
            SizedBox(width: 96, height: 96, child: NetworkImageBox(url: ticket.eventImage)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ticket.eventName, style: Theme.of(context).textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(formatEventDate(ticket.eventDateTime), style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(ticket.categoryName, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.chevron_right, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
