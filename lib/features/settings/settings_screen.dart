import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_buddy_app/core/theme/theme_notifier.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Appearance'),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.instance,
            builder: (context, mode, _) => SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: mode == ThemeMode.dark,
              onChanged: (_) => ThemeNotifier.instance.toggle(),
              secondary: Icon(
                mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: mode == ThemeMode.dark ? Colors.amber : Colors.blueGrey,
              ),
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for book requests & updates'),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(Icons.notifications_outlined),
          ),
          const Divider(),
          const _SectionHeader(title: 'Addresses'),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Manage Addresses'),
            subtitle: const Text('Add or edit delivery addresses'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/addresses'),
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About ReadBuddy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'ReadBuddy',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 ReadBuddy. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'A global library platform for sharing, borrowing, and enjoying books in all formats.',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
