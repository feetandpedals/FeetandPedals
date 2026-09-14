import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/checkout.dart';
import '../models/event.dart';
import '../models/event_ticket_type.dart';
import 'repository_providers.dart';

/// Ticket-quantity selections for the event currently being registered for,
/// keyed by ticket type id (the "Category Selection" step of Registration).
class CartState {
  final EventDetails? event;
  final Map<String, int> quantities;

  const CartState({this.event, this.quantities = const {}});

  int quantityFor(String ticketTypeId) => quantities[ticketTypeId] ?? 0;

  List<TicketSelection> get selections {
    if (event == null) return const [];
    return quantities.entries.where((e) => e.value > 0).map((e) {
      final type = event!.ticketTypes.firstWhere((t) => t.id == e.key);
      return TicketSelection(
        ticketTypeId: type.id,
        ticketTypeName: type.name,
        unitPrice: type.discountedPrice,
        quantity: e.value,
      );
    }).toList();
  }

  double get total => selections.fold<double>(0, (sum, s) => sum + s.subtotal);
  int get totalTickets => quantities.values.fold<int>(0, (a, b) => a + b);

  CartState copyWith({EventDetails? event, Map<String, int>? quantities}) {
    return CartState(event: event ?? this.event, quantities: quantities ?? this.quantities);
  }
}

class CartController extends StateNotifier<CartState> {
  CartController() : super(const CartState());

  void startFor(EventDetails event) {
    if (state.event?.id != event.id) {
      state = CartState(event: event, quantities: const {});
    }
  }

  void setQuantity(EventTicketType type, int quantity) {
    final next = Map<String, int>.from(state.quantities);
    if (quantity <= 0) {
      next.remove(type.id);
    } else {
      // The per-order cap is the *event's* ticket_max_buy (confirmed live:
      // 150-2500), not a ticket type's number_of_tickets, which is total
      // inventory for that type, not a sane per-order limit. Also never
      // exceed remaining inventory when it's known.
      final eventCap = state.event?.ticketMaxBuy ?? 10;
      final cap = type.totalAvailable > 0 ? eventCap.clamp(0, type.totalAvailable) : eventCap;
      next[type.id] = quantity.clamp(0, cap);
    }
    state = state.copyWith(quantities: next);
  }

  void clear() => state = const CartState();
}

final cartControllerProvider = StateNotifierProvider<CartController, CartState>((ref) => CartController());

final paymentOptionsProvider = FutureProvider.autoDispose<List<PaymentOption>>((ref) {
  return ref.watch(checkoutRepositoryProvider).fetchPaymentOptions();
});

class CheckoutState {
  final ParticipantDetails? participant;
  final bool acceptedWaiver;
  final String? selectedGatewayId;
  final bool isSubmitting;
  final String? errorMessage;
  final PurchaseResult? completedOrder;

  const CheckoutState({
    this.participant,
    this.acceptedWaiver = false,
    this.selectedGatewayId,
    this.isSubmitting = false,
    this.errorMessage,
    this.completedOrder,
  });

  CheckoutState copyWith({
    ParticipantDetails? participant,
    bool? acceptedWaiver,
    String? selectedGatewayId,
    bool? isSubmitting,
    String? errorMessage,
    PurchaseResult? completedOrder,
    bool clearError = false,
  }) {
    return CheckoutState(
      participant: participant ?? this.participant,
      acceptedWaiver: acceptedWaiver ?? this.acceptedWaiver,
      selectedGatewayId: selectedGatewayId ?? this.selectedGatewayId,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      completedOrder: completedOrder ?? this.completedOrder,
    );
  }
}

class CheckoutController extends StateNotifier<CheckoutState> {
  CheckoutController(this._ref) : super(const CheckoutState());

  final Ref _ref;

  void setParticipant(ParticipantDetails participant) {
    state = state.copyWith(participant: participant);
  }

  void setAcceptedWaiver(bool value) => state = state.copyWith(acceptedWaiver: value);

  void selectGateway(String gatewayId) => state = state.copyWith(selectedGatewayId: gatewayId);

  Future<bool> submit() async {
    final cart = _ref.read(cartControllerProvider);
    if (cart.event == null || cart.selections.isEmpty) {
      state = state.copyWith(errorMessage: 'Please select at least one category.');
      return false;
    }
    if (state.participant == null) {
      state = state.copyWith(errorMessage: 'Please complete participant details.');
      return false;
    }
    if (!state.acceptedWaiver) {
      state = state.copyWith(errorMessage: 'Please accept the terms and waiver.');
      return false;
    }
    if (state.selectedGatewayId == null) {
      state = state.copyWith(errorMessage: 'Please select a payment method.');
      return false;
    }
    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final order = await _ref.read(checkoutRepositoryProvider).placeOrder(
            eventId: cart.event!.id,
            participant: state.participant!,
            tickets: cart.selections,
            gatewayId: state.selectedGatewayId!,
          );
      state = state.copyWith(isSubmitting: false, completedOrder: order);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.toString());
      return false;
    }
  }

  void reset() {
    state = const CheckoutState();
    _ref.read(cartControllerProvider.notifier).clear();
  }
}

final checkoutControllerProvider =
    StateNotifierProvider<CheckoutController, CheckoutState>((ref) => CheckoutController(ref));
