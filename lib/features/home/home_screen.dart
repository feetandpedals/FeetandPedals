import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../models/event_category.dart';
import '../../state/auth_provider.dart';
import '../../state/events_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/event_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  IconData _iconFor(String name) {
    switch (name.toLowerCase()) {
      case 'running':
        return Icons.directions_run;
      case 'cycling':
        return Icons.pedal_bike;
      case 'triathlon':
        return Icons.pool;
      case 'walking':
        return Icons.directions_walk;
      case 'trail':
        return Icons.terrain;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final categoriesAsync = ref.watch(categoriesProvider);
    final featuredAsync = ref.watch(featuredEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(featuredEventsProvider);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Good Morning', style: Theme.of(context).textTheme.bodyMedium),
                      Text(
                        user?.fullName.split(' ').first ?? 'Athlete',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.outline,
                    backgroundImage: (user?.imageUrl.isNotEmpty ?? false) ? NetworkImage(user!.imageUrl) : null,
                    child: (user?.imageUrl.isEmpty ?? true)
                        ? Text(
                            (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : 'A',
                            style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () => context.push('/events'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppColors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Search events, locations or sports', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.ink, Color(0xFF2A2C34)]),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'RUN\nRIDE\nBELONG',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.white, height: 1.15),
                            ),
                            const SizedBox(height: 14),
                            ElevatedButton(onPressed: () => context.push('/events'), child: const Text('Find Events')),
                          ],
                        ),
                      ),
                      const Icon(Icons.terrain_rounded, color: AppColors.primary, size: 64),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              categoriesAsync.when(
                data: (categories) => SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 16),
                    itemBuilder: (context, index) {
                      final EventCategoryTag category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(eventCategoryFilterProvider.notifier).state = category.id;
                          context.push('/events');
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.outline)),
                              child: Icon(_iconFor(category.name), color: AppColors.primary),
                            ),
                            const SizedBox(height: 6),
                            Text(category.name, style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                loading: () => const SizedBox(height: 84, child: LoadingView()),
                error: (e, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Featured Events', style: Theme.of(context).textTheme.titleLarge),
                  TextButton(onPressed: () => context.push('/events'), child: const Text('View All')),
                ],
              ),
              const SizedBox(height: 8),
              featuredAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return const EmptyStateView(
                      icon: Icons.event_busy_outlined,
                      title: 'No events yet',
                      message: 'Check back soon for upcoming events.',
                    );
                  }
                  return Column(
                    children: events
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: EventCard(event: e, onTap: () => context.push('/events/${e.id}')),
                            ))
                        .toList(),
                  );
                },
                loading: () => const Padding(padding: EdgeInsets.only(top: 40), child: LoadingView()),
                error: (e, _) => ErrorView(message: 'Could not load events.', onRetry: () => ref.invalidate(featuredEventsProvider)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
