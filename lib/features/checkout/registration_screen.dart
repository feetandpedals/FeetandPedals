import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/checkout.dart';
import '../../models/event.dart';
import '../../models/event_ticket_type.dart';
import '../../state/checkout_provider.dart';
import '../../state/events_provider.dart';
import '../../widgets/common.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String eventId;
  const RegistrationScreen({super.key, required this.eventId});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

const _stepLabels = ['Participant', 'Category', 'Add-ons', 'Review'];

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  int _step = 0;
  bool _started = false;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _dob = TextEditingController();
  final _emergencyContact = TextEditingController();
  String _gender = 'Male';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _dob.dispose();
    _emergencyContact.dispose();
    super.dispose();
  }

  void _next(EventDetails event) {
    if (_step == 0) {
      if (!_formKey.currentState!.validate()) return;
      ref.read(checkoutControllerProvider.notifier).setParticipant(ParticipantDetails(
            fullName: _name.text.trim(),
            email: _email.text.trim(),
            dateOfBirth: _dob.text.trim(),
            gender: _gender,
            emergencyContact: _emergencyContact.text.trim(),
          ));
    }
    if (_step == 1) {
      final cart = ref.read(cartControllerProvider);
      if (cart.selections.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one category.')));
        return;
      }
    }
    if (_step < _stepLabels.length - 1) {
      setState(() => _step++);
    } else {
      context.push('/checkout/payment');
    }
  }

  void _back() {
    if (_step == 0) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Registration'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)),
      body: eventAsync.when(
        data: (event) {
          if (!_started) {
            _started = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(cartControllerProvider.notifier).startFor(event);
            });
          }
          return Column(
            children: [
              _StepIndicator(current: _step),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IndexedStack(
                    index: _step,
                    children: [
                      _ParticipantStep(
                        formKey: _formKey,
                        name: _name,
                        email: _email,
                        dob: _dob,
                        emergencyContact: _emergencyContact,
                        gender: _gender,
                        onGenderChanged: (v) => setState(() => _gender = v),
                      ),
                      _CategoryStep(event: event),
                      const _AddOnsStep(),
                      _ReviewStep(event: event),
                    ],
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: ElevatedButton(
                    onPressed: () => _next(event),
                    child: Text(_step == _stepLabels.length - 1 ? 'Continue to Payment' : 'Next'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: 'Could not load this event.'),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: List.generate(_stepLabels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final leftDone = current > (i - 1) ~/ 2;
            return Expanded(child: Divider(color: leftDone ? AppColors.primary : AppColors.outline, thickness: 2));
          }
          final index = i ~/ 2;
          final active = index == current;
          final done = index < current;
          return Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: done || active ? AppColors.primary : AppColors.outline,
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text('${index + 1}', style: TextStyle(color: active ? Colors.white : AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: 4),
              Text(_stepLabels[index], style: TextStyle(fontSize: 10, color: active ? AppColors.primary : AppColors.textSecondary)),
            ],
          );
        }),
      ),
    );
  }
}

class _ParticipantStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController dob;
  final TextEditingController emergencyContact;
  final String gender;
  final ValueChanged<String> onGenderChanged;

  const _ParticipantStep({
    required this.formKey,
    required this.name,
    required this.email,
    required this.dob,
    required this.emergencyContact,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Participant Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Full Name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: dob,
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Date of Birth', suffixIcon: Icon(Icons.calendar_today_outlined)),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                  initialDate: DateTime(2000),
                );
                if (picked != null) dob.text = formatEventDate(picked);
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: gender,
              decoration: const InputDecoration(labelText: 'Gender'),
              items: const ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (v) => v != null ? onGenderChanged(v) : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: emergencyContact,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Emergency Contact'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryStep extends ConsumerWidget {
  final EventDetails event;
  const _CategoryStep({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Category', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          for (final type in event.ticketTypes) ...[
            _CategoryTile(type: type, quantity: cart.quantityFor(type.id)),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _CategoryTile extends ConsumerWidget {
  final EventTicketType type;
  final int quantity;
  const _CategoryTile({required this.type, required this.quantity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = quantity > 0;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? AppColors.primary : AppColors.outline, width: selected ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type.name, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(type.isFree ? 'Free' : formatCurrency(type.discountedPrice),
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          _Stepper(
            quantity: quantity,
            onChanged: (q) => ref.read(cartControllerProvider.notifier).setQuantity(type, q),
          ),
        ],
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundIconButton(icon: Icons.remove, onTap: quantity > 0 ? () => onChanged(quantity - 1) : null),
        SizedBox(width: 28, child: Center(child: Text('$quantity', style: Theme.of(context).textTheme.titleSmall))),
        _RoundIconButton(icon: Icons.add, onTap: () => onChanged(quantity + 1)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIconButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: onTap == null ? AppColors.outline : AppColors.ink,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _AddOnsStep extends StatelessWidget {
  const _AddOnsStep();

  @override
  Widget build(BuildContext context) {
    return const EmptyStateView(
      icon: Icons.add_shopping_cart_outlined,
      title: 'No add-ons available',
      message: 'This event does not offer any add-ons. You can continue to the next step.',
    );
  }
}

class _ReviewStep extends ConsumerWidget {
  final EventDetails event;
  const _ReviewStep({required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider);
    final checkout = ref.watch(checkoutControllerProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text(event.name, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(event.location.displayLine, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          const Divider(),
          for (final s in cart.selections)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Expanded(child: Text('${s.ticketTypeName} x${s.quantity}')),
                  Text(formatCurrencyOrFree(s.subtotal)),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              const Expanded(child: Text('Total', style: TextStyle(fontWeight: FontWeight.w800))),
              Text(formatCurrencyOrFree(cart.total), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
            value: checkout.acceptedWaiver,
            onChanged: (v) => ref.read(checkoutControllerProvider.notifier).setAcceptedWaiver(v ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            title: const Text('I agree to the Terms & Conditions and Event Waiver', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
