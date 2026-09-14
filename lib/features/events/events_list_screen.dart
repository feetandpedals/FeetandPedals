import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../state/events_provider.dart';
import '../../widgets/common.dart';
import '../../widgets/event_card.dart';

class EventsListScreen extends ConsumerStatefulWidget {
  const EventsListScreen({super.key});

  @override
  ConsumerState<EventsListScreen> createState() => _EventsListScreenState();
}

class _EventsListScreenState extends ConsumerState<EventsListScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: ref.read(eventSearchQueryProvider));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(eventCategoryFilterProvider);
    final eventsAsync = ref.watch(filteredEventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Events')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(hintText: 'Search events...', prefixIcon: Icon(Icons.search)),
                    onSubmitted: (v) => ref.read(eventSearchQueryProvider.notifier).state = v,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 44,
            child: categoriesAsync.when(
              data: (categories) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: selectedCategory == null,
                    onTap: () => ref.read(eventCategoryFilterProvider.notifier).state = null,
                  ),
                  const SizedBox(width: 10),
                  for (final c in categories) ...[
                    _CategoryChip(
                      label: c.name,
                      selected: selectedCategory == c.id,
                      onTap: () => ref.read(eventCategoryFilterProvider.notifier).state = c.id,
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: eventsAsync.when(
              data: (events) {
                if (events.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.search_off,
                    title: 'No events found',
                    message: 'Try a different search term or category.',
                  );
                }
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => ref.invalidate(filteredEventsProvider),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: events.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return EventCard(event: event, onTap: () => context.push('/events/${event.id}'));
                    },
                  ),
                );
              },
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: 'Could not load events.', onRetry: () => ref.invalidate(filteredEventsProvider)),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
