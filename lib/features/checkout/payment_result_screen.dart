import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../state/checkout_provider.dart';
import '../../state/tickets_provider.dart';

class PaymentResultScreen extends ConsumerWidget {
  const PaymentResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(checkoutControllerProvider).completedOrder;

    final bool success = order?.status == 'completed';
    final bool pending = order?.status == 'pending';

    final Color color = success ? AppColors.success : (pending ? Colors.orange : AppColors.error);
    final IconData icon = success ? Icons.check_circle : (pending ? Icons.hourglass_top : Icons.error);
    final String title = success ? 'Payment Successful' : (pending ? 'Payment Pending' : 'Payment Failed');
    final String message = success
        ? 'Your registration is confirmed. Your ticket is ready in My Tickets.'
        : pending
            ? "We're confirming your payment. You'll be notified once it's complete."
            : 'Something went wrong processing your payment. Please try again.';

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 84),
                const SizedBox(height: 20),
                Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 10),
                Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                if (order != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      children: [
                        _kv(context, 'Transaction ID', order.trx),
                        const SizedBox(height: 8),
                        _kv(context, 'Amount', formatCurrencyOrFree(order.finalAmount)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(checkoutControllerProvider.notifier).reset();
                      ref.invalidate(myTicketsProvider);
                      context.go(success ? '/tickets' : '/home');
                    },
                    child: Text(success ? 'View My Ticket' : 'Back to Home'),
                  ),
                ),
                if (!success) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      ref.read(checkoutControllerProvider.notifier).reset();
                      context.go('/home');
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.titleSmall),
      ],
    );
  }
}
