import 'dart:math';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';
import '../../models/api_response.dart';
import '../../models/checkout.dart';

abstract class CheckoutRepository {
  Future<List<PaymentOption>> fetchPaymentOptions();
  Future<PurchaseResult> placeOrder({
    required String eventId,
    required ParticipantDetails participant,
    required List<TicketSelection> tickets,
    required String gatewayId,
  });
}

class MockCheckoutRepository implements CheckoutRepository {
  @override
  Future<List<PaymentOption>> fetchPaymentOptions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Live-verified against GET https://feetandpedals.com/api/gateways:
    // this deployment currently has exactly one gateway enabled —
    // Razorpay (id 01m234gt1dqs788xbwh3bkv4ma, gateway_type "autometic" —
    // a typo in their own data for "automatic", as opposed to a manual/
    // bank-transfer gateway). Eventiq's generic docs list PayPal/Stripe/
    // SSLCommerz/Flutterwave/Paystack/Bank as *possible* gateways, but only
    // what GET /api/gateways actually returns is live for this deployment.
    return const [
      PaymentOption(id: '01m234gt1dqs788xbwh3bkv4ma', name: 'Razorpay', gatewayType: 'autometic'),
    ];
  }

  @override
  Future<PurchaseResult> placeOrder({
    required String eventId,
    required ParticipantDetails participant,
    required List<TicketSelection> tickets,
    required String gatewayId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final total = tickets.fold<double>(0, (sum, t) => sum + t.subtotal);
    final id = 'PUR${DateTime.now().millisecondsSinceEpoch}';
    return PurchaseResult(
      purchaseId: id,
      trx: 'FP${Random().nextInt(999999).toString().padLeft(6, '0')}',
      status: 'completed',
      finalAmount: total,
    );
  }
}

/// Talks to the existing Laravel/Eventiq REST API (`/gateways`,
/// `/checkout-confirmation`) per `ApiEndpoints`. The mobile app never marks
/// an order paid itself — Laravel confirms it server-side once the gateway
/// webhook fires, per the MVP1 payment architecture doc.
class ApiCheckoutRepository implements CheckoutRepository {
  final ApiClient _client = ApiClient.instance;

  @override
  Future<List<PaymentOption>> fetchPaymentOptions() {
    return _client.request(
      (dio) => dio.get(ApiEndpoints.gateways),
      parse: (data) {
        final response = ApiResponse<List<dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as List<dynamic>,
        );
        return (response.data ?? const [])
            .map((e) => PaymentOption.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  @override
  Future<PurchaseResult> placeOrder({
    required String eventId,
    required ParticipantDetails participant,
    required List<TicketSelection> tickets,
    required String gatewayId,
  }) async {
    // Step 1: reserve tickets. The documented payload
    // (developer-api-architecture.html, POST /api/event-ticket/purchase/{event})
    // is `{ selected_date, tickets: [{id, name, price, quantity}], total_amount }`
    // with no attendee fields — stock Eventiq ticketing has no per-participant
    // form. `participant` is still sent alongside it since the MVP1 scope
    // explicitly requires collecting it (section 4, "Registration /
    // Participant Details") — confirm with the backend team whether this
    // needs a schema addition to persist it, or drop this field if they
    // handle it elsewhere.
    final total = tickets.fold<double>(0, (sum, t) => sum + t.subtotal);
    final purchaseId = await _client.request(
      (dio) => dio.post('${ApiEndpoints.bookTicket}/$eventId', data: {
        'tickets': tickets
            .map((t) => {
                  'id': t.ticketTypeId,
                  'name': t.ticketTypeName,
                  'price': t.unitPrice,
                  'quantity': t.quantity,
                })
            .toList(),
        'total_amount': total,
        'participant': participant.toJson(),
      }),
      parse: (data) {
        final response = ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        );
        // The purchase object's own `id` field is the purchase id — it is
        // not wrapped as `purchase_id`.
        return (response.data?['id'] ?? '').toString();
      },
    );

    // Step 2: confirm checkout against the chosen gateway.
    return _client.request(
      (dio) => dio.post(ApiEndpoints.checkout, data: {
        'purchase_id': purchaseId,
        'gateway_id': gatewayId,
        'from': 'app',
      }),
      parse: (data) => PurchaseResult.fromJson(
        (ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        ).data) ??
            const {},
      ),
    );
  }
}

CheckoutRepository createCheckoutRepository() =>
    Env.useMockData ? MockCheckoutRepository() : ApiCheckoutRepository();
