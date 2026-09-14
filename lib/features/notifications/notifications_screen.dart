import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../models/app_notification.dart';
import '../../state/notifications_provider.dart';
import '../../widgets/common.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  IconData _iconFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.registration:
        return Icons.check_circle;
      case NotificationKind.event:
        return Icons.campaign;
      case NotificationKind.payment:
        return Icons.payments;
      case NotificationKind.promotion:
        return Icons.local_offer;
      case NotificationKind.general:
        return Icons.notifications;
    }
  }

  Color _colorFor(NotificationKind kind) {
    switch (kind) {
      case NotificationKind.registration:
        return AppColors.success;
      case NotificationKind.payment:
        return AppColors.success;
      case NotificationKind.event:
        return AppColors.primary;
      case NotificationKind.promotion:
        return Colors.orange;
      case NotificationKind.general:
        return AppColors.textSecondary;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'All'), Tab(text: 'Updates'), Tab(text: 'Promotions')],
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          final updates = notifications.where((n) => !n.isPromotion).toList();
          final promotions = notifications.where((n) => n.isPromotion).toList();
          return TabBarView(
            controller: _tabController,
            children: [
              _list(notifications),
              _list(updates),
              _list(promotions),
            ],
          );
        },
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: 'Could not load notifications.', onRetry: () => ref.invalidate(notificationsProvider)),
      ),
    );
  }

  Widget _list(List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const EmptyStateView(icon: Icons.notifications_none, title: 'Nothing here yet', message: "You're all caught up.");
    }
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final n = notifications[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: n.isRead ? AppColors.surface : AppColors.primary.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _colorFor(n.kind).withValues(alpha: 0.12),
                child: Icon(_iconFor(n.kind), size: 18, color: _colorFor(n.kind)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title, style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 3),
                    Text(n.body, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    Text(_timeAgo(n.createdAt), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
            ],
          ),
        );
      },
    );
  }
}
