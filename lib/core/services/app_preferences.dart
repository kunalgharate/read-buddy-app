import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _keyIsLoggedIn = 'is_logged_in';
  static const _keyHasSeenOnboarding = 'has_seen_onboarding';
  static const _keyAppVersion = 'app_version';
  static const _currentVersion = 1;

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
    await prefs.setInt(_keyAppVersion, _currentVersion);
  }

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final storedVersion = prefs.getInt(_keyAppVersion) ?? 0;
    if (storedVersion < _currentVersion) {
      return false;
    }
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  // ---------- Clear All ----------
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
  }
}
