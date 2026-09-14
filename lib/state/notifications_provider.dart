import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_notification.dart';
import 'repository_providers.dart';

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) {
  return ref.watch(notificationRepositoryProvider).fetchNotifications();
});

final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final async = ref.watch(notificationsProvider);
  return async.maybeWhen(data: (list) => list.where((n) => !n.isRead).length, orElse: () => 0);
});
