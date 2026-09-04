import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'location_service.dart';

/// App-wide city state. Singleton accessed via CityNotifier.instance.
///
/// Value is the currently selected city name (e.g. "Pune", "Mumbai").
/// Persists to SharedPreferences so the user's last-selected city is
/// restored on next launch. Also stores recent locations for quick switching.
///
/// Usage:
///   await CityNotifier.instance.init();       // call once at startup
///   CityNotifier.instance.value               // current city or null
///   CityNotifier.instance.setCity('Mumbai');   // switch city
///   CityNotifier.instance.detectFromGPS();     // auto-detect via GPS
///   CityNotifier.instance.recentCities         // list of recent cities
class CityNotifier extends ValueNotifier<String?> {
  CityNotifier._() : super(null);
  static final instance = CityNotifier._();

  static const _keyCity = 'selected_city';
  static const _keyRecent = 'recent_cities';
  static const _maxRecent = 5;

  List<String> _recentCities = [];

  /// Recent cities the user has selected (most recent first).
  List<String> get recentCities => List.unmodifiable(_recentCities);

  /// Initialize: load saved city from SharedPreferences.
  /// If no saved city, attempt GPS detection.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_keyCity);
    final recentJson = prefs.getString(_keyRecent);

    if (recentJson != null) {
      try {
        _recentCities = List<String>.from(jsonDecode(recentJson));
      } catch (_) {
        _recentCities = [];
      }
    }

    if (saved != null && saved.isNotEmpty) {
      value = saved;
    } else {
      // No saved city — try GPS on first launch
      await detectFromGPS();
    }
  }

  /// Set city manually (user picks from list or types).
  Future<void> setCity(String city) async {
    if (city.trim().isEmpty) return;
    final trimmed = city.trim();
    value = trimmed;

    // Update recents
    _recentCities.remove(trimmed);
    _recentCities.insert(0, trimmed);
    if (_recentCities.length > _maxRecent) {
      _recentCities = _recentCities.sublist(0, _maxRecent);
    }

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCity, trimmed);
    await prefs.setString(_keyRecent, jsonEncode(_recentCities));
  }

  /// Detect city from GPS and set it.
  /// Returns the detected city name, or null if GPS unavailable.
  Future<String?> detectFromGPS() async {
    try {
      final locationService = LocationService.instance;
      final position = await locationService.getCurrentLocation();
      if (position == null) return null;

      final address = await locationService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      if (address != null && address.city.isNotEmpty) {
        await setCity(address.city);
        return address.city;
      }
    } catch (e) {
      if (kDebugMode) print('📍 CityNotifier GPS detect failed: $e');
    }
    return null;
  }

  /// Clear saved city (reset to unset).
  Future<void> clear() async {
    value = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCity);
  }
}
