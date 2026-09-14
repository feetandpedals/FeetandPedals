import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Auth bootstrap runs in AuthController's constructor; app_router's
    // redirect moves on to /login or /home as soon as status resolves.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.ink, Color(0xFF262832)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.terrain_rounded, color: AppColors.primary, size: 72),
            const SizedBox(height: 16),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'FEET ',
                    style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                  TextSpan(
                    text: 'AND PEDALS',
                    style: TextStyle(color: AppColors.primary, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'EVENTS FOR A STRONGER TOMORROW',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, letterSpacing: 2),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
