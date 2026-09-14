import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/utils/formatters.dart';
import '../models/event.dart';
import 'network_image_box.dart';

class EventCard extends StatelessWidget {
  final SportEvent event;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  const EventCard({super.key, required this.event, required this.onTap, this.onFavoriteTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(url: event.imageUrl),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: _FavoriteButton(isFavorite: event.isFavorite, onTap: onFavoriteTap),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(formatEventDate(event.startDateTime), style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          event.location.displayLine,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    event.isFree ? 'Free' : 'From ${formatCurrency(event.startingPriceValue)}',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback? onTap;

  const _FavoriteButton({required this.isFavorite, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: 17,
          color: isFavorite ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
