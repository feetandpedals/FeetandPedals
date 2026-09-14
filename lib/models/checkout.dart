/// A payment method offered by the backend (`GET /gateways`), e.g. Credit
/// Card, FPX, TNG eWallet, GrabPay.
class PaymentOption {
  final String id;
  final String name;
  final String gatewayType;
  final String imageUrl;

  const PaymentOption({
    required this.id,
    required this.name,
    this.gatewayType = '',
    this.imageUrl = '',
  });

  factory PaymentOption.fromJson(Map<String, dynamic> json) {
    return PaymentOption(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      gatewayType: (json['gateway_type'] ?? '').toString(),
      imageUrl: (json['image_url'] ?? '').toString(),
    );
  }
}

/// One ticket-type selection in a registration/purchase request.
class TicketSelection {
  final String ticketTypeId;
  final String ticketTypeName;
  final double unitPrice;
  final int quantity;

  const TicketSelection({
    required this.ticketTypeId,
    required this.ticketTypeName,
    required this.unitPrice,
    required this.quantity,
  });

  double get subtotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {'ticket_id': ticketTypeId, 'quantity': quantity};
}

/// Participant details collected on the Registration screen.
class ParticipantDetails {
  final String fullName;
  final String email;
  final String dateOfBirth;
  final String gender;
  final String emergencyContact;

  const ParticipantDetails({
    required this.fullName,
    required this.email,
    this.dateOfBirth = '',
    this.gender = '',
    this.emergencyContact = '',
  });

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'email': email,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'emergency_contact': emergencyContact,
      };
}

/// Result of `POST /checkout-confirmation` (Eventiq's `CheckoutResponse` /
/// `Purchase`).
class PurchaseResult {
  final String purchaseId;
  final String trx;
  final String status; // pending | completed | failed
  final double finalAmount;
  final String? redirectUrl;

  const PurchaseResult({
    required this.purchaseId,
    this.trx = '',
    this.status = 'pending',
    this.finalAmount = 0,
    this.redirectUrl,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) {
    final purchase = json['purchase'] as Map<String, dynamic>? ?? json;
    return PurchaseResult(
      purchaseId: (purchase['id'] ?? '').toString(),
      trx: (purchase['trx'] ?? '').toString(),
      status: (purchase['status'] ?? 'pending').toString(),
      finalAmount: double.tryParse((purchase['final_amount'] ?? '0').toString()) ?? 0,
      redirectUrl: json['url'] as String?,
    );
  }
}
