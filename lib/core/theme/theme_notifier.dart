import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global theme notifier. Widgets listen via ValueListenableBuilder.
class ThemeNotifier extends ValueNotifier<ThemeMode> {
  ThemeNotifier._() : super(ThemeMode.light);
  static final instance = ThemeNotifier._();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('dark_mode') ?? false;
    value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newMode = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await prefs.setBool('dark_mode', newMode == ThemeMode.dark);
    value = newMode;
  }

  bool get isDark => value == ThemeMode.dark;
}
