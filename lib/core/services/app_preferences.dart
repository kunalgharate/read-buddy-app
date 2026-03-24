// core/utils/app_preferences.dart
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyHasSeenOnboarding = 'has_seen_onboarding'; // ← new

  // ---------- Login ----------
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, value);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  // ---------- Intro Slides ----------
  static Future<void> setHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  // ---------- Clear All ----------
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    // Keep hasSeenOnboarding — slides never show again even after logout
    await prefs.remove(_keyIsLoggedIn);
  }
}
