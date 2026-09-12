import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global locale notifier. Widgets listen via ValueListenableBuilder.
///
/// Mirrors [ThemeNotifier]: a [ValueNotifier] singleton backed by
/// SharedPreferences. The selected locale is persisted under the
/// `app_locale` key (stored as a language code, e.g. `en`, `hi`, `mr`).
class LocaleNotifier extends ValueNotifier<Locale> {
  LocaleNotifier._() : super(const Locale('en'));
  static final instance = LocaleNotifier._();

  static const String _prefsKey = 'app_locale';

  /// Locales the app can display. Keep in sync with `supportedLocales`
  /// wired into `MaterialApp`.
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('mr'),
  ];

  /// Load the persisted locale on startup. Falls back to English.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code != null && _isSupported(code)) {
      value = Locale(code);
    } else {
      value = const Locale('en');
    }
  }

  /// Persist and apply the given [locale].
  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale.languageCode)) return;
    if (value.languageCode == locale.languageCode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    value = Locale(locale.languageCode);
  }

  bool _isSupported(String code) =>
      supportedLocales.any((l) => l.languageCode == code);
}
