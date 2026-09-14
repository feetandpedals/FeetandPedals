enum NotificationKind { registration, event, payment, promotion, general }

NotificationKind _kindFrom(String? type) {
  switch (type) {
    case 'registration':
      return NotificationKind.registration;
    case 'event':
      return NotificationKind.event;
    case 'payment':
      return NotificationKind.payment;
    case 'promotion':
      return NotificationKind.promotion;
    default:
      return NotificationKind.general;
  }
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.kind = NotificationKind.general,
    required this.createdAt,
    this.isRead = false,
  });

  bool get isPromotion => kind == NotificationKind.promotion;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? json['message'] ?? '').toString(),
      kind: _kindFrom(json['type'] as String?),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ?? DateTime.now(),
      isRead: json['is_read'] == true,
    );
  }
}
