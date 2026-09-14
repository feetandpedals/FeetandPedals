import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push Notifications'),
            value: _pushNotifications,
            onChanged: (v) => setState(() => _pushNotifications = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Email Updates'),
            value: _emailUpdates,
            onChanged: (v) => setState(() => _emailUpdates = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Promotions & Offers'),
            value: _promotions,
            onChanged: (v) => setState(() => _promotions = v),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text('About', style: Theme.of(context).textTheme.titleMedium),
          const ListTile(contentPadding: EdgeInsets.zero, title: Text('Version'), trailing: Text('1.0.0', style: TextStyle(color: AppColors.textSecondary))),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Terms & Conditions'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
        ],
      ),
    );
  }
}
