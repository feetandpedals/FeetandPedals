import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/checkout.dart';
import '../../state/checkout_provider.dart';
import '../../widgets/common.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  IconData _iconFor(String gatewayType) {
    switch (gatewayType) {
      case 'stripe':
        return Icons.credit_card;
      case 'paypal':
        return Icons.account_balance_wallet_outlined;
      case 'bank':
        return Icons.account_balance_outlined;
      case 'sslcommerz':
      case 'flutterwave':
      case 'paystack':
        return Icons.payments_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final checkout = ref.watch(checkoutControllerProvider);
    final optionsAsync = ref.watch(paymentOptionsProvider);

    ref.listen(checkoutControllerProvider, (prev, next) {
      if (next.errorMessage != null && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
      if (next.completedOrder != null && prev?.completedOrder != next.completedOrder) {
        context.push('/checkout/result');
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Payment')),
      body: optionsAsync.when(
        data: (options) => Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cart.event != null) ...[
                      Text(cart.event!.name, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text(
                        cart.selections.map((s) => '${s.ticketTypeName} x${s.quantity}').join(', '),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(formatCurrencyOrFree(cart.total),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      const SizedBox(height: 24),
                    ],
                    Text('Select Payment Method', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    for (final option in options) ...[
                      _PaymentTile(
                        option: option,
                        icon: _iconFor(option.gatewayType),
                        selected: checkout.selectedGatewayId == option.id,
                        onTap: () => ref.read(checkoutControllerProvider.notifier).selectGateway(option.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: ElevatedButton.icon(
                  onPressed: checkout.isSubmitting ? null : () => ref.read(checkoutControllerProvider.notifier).submit(),
                  icon: checkout.isSubmitting
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.lock_outline, size: 18),
                  label: Text('Pay Now  ${formatCurrencyOrFree(cart.total)}'),
                ),
              ),
            ),
          ],
        ),
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: 'Could not load payment methods.', onRetry: () => ref.invalidate(paymentOptionsProvider)),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final PaymentOption option;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({required this.option, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: selected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 14),
            Expanded(child: Text(option.name, style: Theme.of(context).textTheme.titleSmall)),
            Radio<String>(
              value: option.id,
              groupValue: selected ? option.id : null,
              onChanged: (_) => onTap(),
            ),
          ],
        ),
      ),
    );
  }
}
