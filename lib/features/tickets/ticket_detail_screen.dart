import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/tickets_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/network_image_box.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String purchaseId;
  const TicketDetailScreen({super.key, required this.purchaseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(myTicketsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Ticket')),
      body: ticketsAsync.when(
        data: (tickets) {
          final ticket = tickets.firstWhereOrNull((t) => t.purchaseId == purchaseId);
          if (ticket == null) {
            return const EmptyStateView(icon: Icons.error_outline, title: 'Ticket not found', message: 'This ticket may have been removed.');
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      AspectRatio(aspectRatio: 16 / 9, child: NetworkImageBox(url: ticket.eventImage)),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Text(ticket.eventName, style: Theme.of(context).textTheme.titleLarge, textAlign: TextAlign.center),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(formatEventDate(ticket.eventDateTime), style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 6),
                                Text(ticket.eventLocation, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.outline)),
                              child: QrImageView(
                                data: ticket.qrCode.isEmpty ? ticket.purchaseId : ticket.qrCode,
                                size: 190,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(ticket.attendeeName.isEmpty ? 'Guest' : ticket.attendeeName, style: Theme.of(context).textTheme.titleMedium),
                            Text(ticket.categoryName, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text('Ticket # ${ticket.trx}', style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                    label: const Text('Add to Wallet'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => const ErrorView(message: 'Could not load this ticket.'),
      ),
    );
  }
}
