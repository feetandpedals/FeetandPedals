import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../state/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.outline,
                backgroundImage: (user?.imageUrl.isNotEmpty ?? false) ? NetworkImage(user!.imageUrl) : null,
                child: (user?.imageUrl.isEmpty ?? true)
                    ? Text(
                        (user?.fullName.isNotEmpty ?? false) ? user!.fullName[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => context.push('/profile/edit'),
                      child: const Text('View & Edit Profile', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _MenuTile(icon: Icons.event_note_outlined, label: 'My Registrations', onTap: () => context.push('/tickets')),
          _MenuTile(icon: Icons.confirmation_number_outlined, label: 'My Tickets', onTap: () => context.push('/tickets')),
          _MenuTile(icon: Icons.favorite_border, label: 'Favourites', onTap: () {}),
          _MenuTile(icon: Icons.notifications_none, label: 'Notifications', onTap: () => context.push('/notifications')),
          _MenuTile(icon: Icons.receipt_long_outlined, label: 'Payment History', onTap: () {}),
          _MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push('/profile/settings')),
          _MenuTile(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout,
            label: 'Log Out',
            color: AppColors.error,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will need to sign in again to access your tickets.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log Out')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: tileColor),
      title: Text(label, style: TextStyle(color: tileColor, fontWeight: FontWeight.w600)),
      trailing: Icon(Icons.chevron_right, color: color ?? AppColors.textSecondary),
    );
  }
}
