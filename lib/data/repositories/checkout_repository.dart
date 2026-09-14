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
    return const [
      PaymentOption(id: 'card', name: 'Credit / Debit Card', gatewayType: 'card'),
      PaymentOption(id: 'upi', name: 'UPI', gatewayType: 'upi'),
      PaymentOption(id: 'netbanking', name: 'Net Banking', gatewayType: 'netbanking'),
      PaymentOption(id: 'wallet', name: 'Wallet', gatewayType: 'wallet'),
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
    // Step 1: register participant + reserve tickets.
    final purchaseId = await _client.request(
      (dio) => dio.post('${ApiEndpoints.bookTicket}/$eventId', data: {
        'participant': participant.toJson(),
        'tickets': tickets.map((t) => t.toJson()).toList(),
      }),
      parse: (data) {
        final response = ApiResponse<Map<String, dynamic>>.fromJson(
          data as Map<String, dynamic>,
          (p0) => p0 as Map<String, dynamic>,
        );
        return (response.data?['purchase_id'] ?? '').toString();
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
