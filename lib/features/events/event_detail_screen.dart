import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../models/event.dart';
import '../../state/events_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/network_image_box.dart';

class EventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync = ref.watch(eventDetailProvider(widget.eventId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: eventAsync.when(
        data: (event) => _EventDetailBody(event: event, tabController: _tabController),
        loading: () => const LoadingView(),
        error: (e, _) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(message: 'Could not load this event.', onRetry: () => ref.invalidate(eventDetailProvider(widget.eventId))),
        ),
      ),
      bottomNavigationBar: eventAsync.maybeWhen(
        data: (event) => _RegisterBar(event: event),
        orElse: () => null,
      ),
    );
  }
}

class _EventDetailBody extends StatelessWidget {
  final EventDetails event;
  final TabController tabController;

  const _EventDetailBody({required this.event, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          backgroundColor: AppColors.background,
          leading: const _CircleBackButton(),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _CircleIconButton(icon: event.isFavorite ? Icons.favorite : Icons.favorite_border, onTap: () {}),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(background: NetworkImageBox(url: event.imageUrl)),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0),
            child: Container(),
          ),
        ),
      ],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.name, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.calendar_today_outlined, text: formatEventDate(event.startDateTime)),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.location_on_outlined, text: event.location.displayLine),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.groups_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(event.organizer.name, style: Theme.of(context).textTheme.bodyMedium)),
                      TextButton(onPressed: () {}, child: const Text('View Organizer')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TabBar(
                    controller: tabController,
                    isScrollable: true,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    labelPadding: const EdgeInsets.only(right: 24),
                    tabAlignment: TabAlignment.start,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Categories'),
                      Tab(text: 'Location'),
                      Tab(text: 'FAQ'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 320,
                    child: TabBarView(
                      controller: tabController,
                      children: [
                        _OverviewTab(event: event),
                        _CategoriesTab(event: event),
                        _LocationTab(event: event),
                        const _FaqTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final EventDetails event;
  const _OverviewTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.details.isEmpty ? 'No description provided.' : event.details,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
          if (event.totalReviews > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.star_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text('${event.averageRating.toStringAsFixed(1)} (${event.totalReviews} reviews)',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  final EventDetails event;
  const _CategoriesTab({required this.event});

  @override
  Widget build(BuildContext context) {
    if (event.ticketTypes.isEmpty) {
      return const EmptyStateView(icon: Icons.category_outlined, title: 'No categories yet', message: 'Categories will appear here once published.');
    }
    return ListView.separated(
      itemCount: event.ticketTypes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final t = event.ticketTypes[index];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            children: [
              Expanded(child: Text(t.name, style: Theme.of(context).textTheme.titleSmall)),
              Text(
                t.isFree ? 'Free' : formatCurrency(t.discountedPrice),
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LocationTab extends StatelessWidget {
  final EventDetails event;
  const _LocationTab({required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 140,
              color: AppColors.outline.withValues(alpha: 0.5),
              alignment: Alignment.center,
              child: const Icon(Icons.map_outlined, size: 40, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Text(event.location.address.isEmpty ? event.location.displayLine : event.location.address,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(event.location.displayLine, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _FaqTab extends StatelessWidget {
  const _FaqTab();

  @override
  Widget build(BuildContext context) {
    const faqs = [
      ('Can I get a refund?', 'Refund policies are set by the organizer and shown at checkout.'),
      ('Is there an age limit?', 'Age requirements vary by category — check the category details.'),
      ('How do I receive my ticket?', 'Your digital ticket with QR code appears in My Tickets after payment is confirmed.'),
    ];
    return ListView.separated(
      itemCount: faqs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final (q, a) = faqs[index];
        return ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(q, style: Theme.of(context).textTheme.titleSmall),
          children: [Padding(padding: const EdgeInsets.only(bottom: 12), child: Text(a, style: Theme.of(context).textTheme.bodyMedium))],
        );
      },
    );
  }
}

class _RegisterBar extends StatelessWidget {
  final EventDetails event;
  const _RegisterBar({required this.event});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outline)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('From', style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    event.isFree ? 'Free' : formatCurrency(event.lowestPrice),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 160,
              child: ElevatedButton(
                onPressed: () => context.push('/events/${event.id}/register'),
                child: const Text('Register Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 4),
      child: _CircleIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 38,
        height: 38,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
