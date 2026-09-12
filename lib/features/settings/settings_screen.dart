import 'package:flutter/material.dart';
import 'package:read_buddy_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:read_buddy_app/core/theme/theme_notifier.dart';
import 'package:read_buddy_app/core/theme/locale_notifier.dart';

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

  String _languageLabel(AppLocalizations l10n, String code) {
    switch (code) {
      case 'hi':
        return l10n.hindi;
      case 'mr':
        return l10n.marathi;
      case 'en':
      default:
        return l10n.english;
    }
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final currentCode = LocaleNotifier.instance.value.languageCode;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.language,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              for (final locale in LocaleNotifier.supportedLocales)
                RadioGroup<String>(
                  groupValue: currentCode,
                  onChanged: (code) {
                    if (code != null) {
                      LocaleNotifier.instance.setLocale(Locale(code));
                    }
                    Navigator.pop(sheetContext);
                  },
                  child: RadioListTile<String>(
                    value: locale.languageCode,
                    title: Text(_languageLabel(l10n, locale.languageCode)),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l10n.membership),
          ListTile(
            leading:
                const Icon(Icons.workspace_premium, color: Color(0xFF2CE07F)),
            title: Text(l10n.readBuddyPrime),
            subtitle: Text(l10n.readBuddyPrimeSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/subscription'),
          ),
          const Divider(),
          _SectionHeader(title: l10n.appearance),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeNotifier.instance,
            builder: (context, mode, _) => SwitchListTile(
              title: Text(l10n.darkMode),
              subtitle: Text(l10n.darkModeSubtitle),
              value: mode == ThemeMode.dark,
              onChanged: (_) => ThemeNotifier.instance.toggle(),
              secondary: Icon(
                mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: mode == ThemeMode.dark ? Colors.amber : Colors.blueGrey,
              ),
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.language),
          ValueListenableBuilder<Locale>(
            valueListenable: LocaleNotifier.instance,
            builder: (context, locale, _) => ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.language),
              subtitle: Text(_languageLabel(l10n, locale.languageCode)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguagePicker(context),
            ),
          ),
          const Divider(),
          _SectionHeader(title: l10n.notifications),
          SwitchListTile(
            title: Text(l10n.pushNotifications),
            subtitle: Text(l10n.pushNotificationsSubtitle),
            value: _notificationsEnabled,
            onChanged: _toggleNotifications,
            secondary: const Icon(Icons.notifications_outlined),
          ),
          const Divider(),
          _SectionHeader(title: l10n.addresses),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: Text(l10n.manageAddresses),
            subtitle: Text(l10n.manageAddressesSubtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/addresses'),
          ),
          const Divider(),
          _SectionHeader(title: l10n.account),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: Text(l10n.changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/change-password'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline),
            title: Text(l10n.myWishlist),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/wishlist'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: Text(l10n.myOrders),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/my-orders'),
          ),
          ListTile(
            leading: const Icon(Icons.play_circle_outline),
            title: Text(l10n.videoCourses),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/video-courses'),
          ),
          const Divider(),
          _SectionHeader(title: l10n.legalAndPolicies),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l10n.termsOfService),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/terms'),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l10n.refundPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/refund-policy'),
          ),
          ListTile(
            leading: const Icon(Icons.copyright_outlined),
            title: Text(l10n.copyrightAndTakedown),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/copyright'),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(l10n.helpAndFaq),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, '/faq'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.aboutReadBuddy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showAboutDialog(
      context: context,
      applicationName: 'ReadBuddy',
      applicationVersion: '1.0.0',
      applicationLegalese: l10n.aboutReadBuddyLegalese,
      children: [
        const SizedBox(height: 16),
        Text(l10n.aboutReadBuddyDescription),
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
