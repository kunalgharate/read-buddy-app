import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for GPS location, distance calculation, and reverse geocoding.
/// Used by both admin (library creation) and user (nearest library).
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Position? _lastPosition;
  DateTime? _lastFixAt;

  /// How long a cached fix is considered fresh enough to reuse without
  /// hitting the GPS again. Keeps repeated calls (home tab, pickup picker,
  /// library details) from each triggering a slow cold fix.
  static const _cacheDuration = Duration(seconds: 30);

  /// Returns the last known position without requesting a new one.
  Position? get lastPosition => _lastPosition;

  // ─── Permission ──────────────────────────────────────────────────────────

  /// Check if location services are enabled and permission is granted.
  /// Returns true if ready to use, false otherwise.
  Future<bool> isLocationAvailable() async {
    if (!await Geolocator.isLocationServiceEnabled()) return false;
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Whether the device-level location service (GPS) is switched on.
  /// Separate from permission so callers can send the user to the right
  /// settings screen: services off -> location settings, permission denied
  /// -> app settings.
  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  /// Request location permission. Returns true if granted.
  Future<bool> requestPermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      if (kDebugMode) print('📍 Location services are disabled');
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (kDebugMode) {
        print('📍 Location permission permanently denied');
      }
      return false;
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  // ─── Current Location ────────────────────────────────────────────────────

  /// Get user's current GPS coordinates.
  /// Returns null if permission denied or service unavailable.
  Future<Position?> getCurrentLocation() async {
    // Reuse a very recent fix so consumers calling in sequence don't each
    // wait on a fresh GPS lock.
    final cachedAt = _lastFixAt;
    if (_lastPosition != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheDuration) {
      return _lastPosition;
    }

    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    // Grab the last known fix first: it is instant and makes detection work
    // when the live fix is slow or times out indoors.
    Position? lastKnown;
    try {
      lastKnown = await Geolocator.getLastKnownPosition();
    } catch (_) {
      lastKnown = null;
    }

    // Try a fast, lower-accuracy fix first, then a high-accuracy one. A cold
    // GPS frequently times out on the first attempt; two attempts plus the
    // last-known fallback keep "Detect location" from failing outright.
    const attempts = [
      LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 10),
      ),
      LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    ];

    for (final settings in attempts) {
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: settings,
        );
        _cache(position);
        return position;
      } catch (e) {
        if (kDebugMode) {
          print('📍 ${settings.accuracy.name} fix failed: $e');
        }
      }
    }

    if (lastKnown != null) {
      _cache(lastKnown);
      if (kDebugMode) {
        print('📍 Location (last known): '
            '${lastKnown.latitude}, ${lastKnown.longitude}');
      }
      return lastKnown;
    }

    if (kDebugMode) print('📍 Could not obtain any location fix');
    return null;
  }

  void _cache(Position position) {
    _lastPosition = position;
    _lastFixAt = DateTime.now();
    if (kDebugMode) {
      print('📍 Location: ${position.latitude}, ${position.longitude}');
    }
  }

  // ─── Distance ────────────────────────────────────────────────────────────

  /// Calculate distance between two coordinates in kilometers.
  double calculateDistanceKm(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    final meters = Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
    return meters / 1000.0;
  }

  /// Format distance for display: "2.3 km" or "500 m"
  String formatDistance(double distanceKm) {
    if (distanceKm < 1.0) {
      return '${(distanceKm * 1000).round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  // ─── Reverse Geocoding ───────────────────────────────────────────────────

  /// Convert latitude/longitude to a human-readable address.
  /// Returns null if geocoding fails.
  Future<PlacemarkAddress?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    List<Placemark> placemarks;
    try {
      placemarks = await placemarkFromCoordinates(latitude, longitude);
    } catch (e) {
      // The platform geocoder is occasionally flaky on a cold start; a single
      // retry avoids reporting a valid GPS fix as an undetectable city.
      if (kDebugMode) print('📍 Reverse geocode attempt failed: $e');
      try {
        await Future<void>.delayed(const Duration(milliseconds: 400));
        placemarks = await placemarkFromCoordinates(latitude, longitude);
      } catch (e2) {
        if (kDebugMode) print('📍 Reverse geocode failed: $e2');
        return null;
      }
    }
    try {
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      // `locality` is null for many valid fixes (villages, new developments,
      // some Android geocoders). Walk through the narrower/wider admin fields
      // so a successful GPS fix is not reported as "location unavailable" just
      // because the city label came back empty.
      final city = [
        p.locality,
        p.subAdministrativeArea,
        p.subLocality,
        p.administrativeArea,
      ].firstWhere(
        (s) => s != null && s.trim().isNotEmpty,
        orElse: () => '',
      )!;
      final street = [
        p.thoroughfare,
        p.street,
        p.subLocality,
      ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
      return PlacemarkAddress(
        street: street,
        city: city,
        state: p.administrativeArea ?? '',
        country: p.country ?? '',
        pincode: p.postalCode ?? '',
        latitude: latitude,
        longitude: longitude,
      );
    } catch (e) {
      if (kDebugMode) print('📍 Reverse geocode failed: $e');
      return null;
    }
  }

  /// Open device location settings (if permission permanently denied).
  Future<bool> openSettings() => Geolocator.openLocationSettings();

  // ─── Forward Geocoding (address → coordinates) ─────────────────────────────

  /// Convert a textual address into coordinates. Used by the admin library
  /// form so a library always gets proper coordinates (nearby/pickup depend on
  /// this). Returns null when the address can't be resolved.
  Future<({double latitude, double longitude})?> forwardGeocode({
    String? street,
    String? city,
    String? state,
    String? pincode,
    String country = 'India',
  }) async {
    final query = [street, city, state, pincode, country]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(', ');
    if (query.trim().isEmpty) return null;
    try {
      final locations = await locationFromAddress(query);
      if (locations.isEmpty) return null;
      final l = locations.first;
      return (latitude: l.latitude, longitude: l.longitude);
    } catch (e) {
      if (kDebugMode) print('📍 Forward geocode failed for "$query": $e');
      return null;
    }
  }

  /// Open app settings (for permission denied forever).
  Future<bool> openAppSettings() => Geolocator.openAppSettings();
}

/// Structured address from reverse geocoding.
class PlacemarkAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String pincode;
  final double latitude;
  final double longitude;

  const PlacemarkAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.latitude,
    required this.longitude,
  });

  String get fullAddress =>
      [street, city, state, pincode].where((s) => s.isNotEmpty).join(', ');
}
