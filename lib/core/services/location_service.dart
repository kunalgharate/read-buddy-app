import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Service for GPS location, distance calculation, and reverse geocoding.
/// Used by both admin (library creation) and user (nearest library).
class LocationService {
  LocationService._();
  static final instance = LocationService._();

  Position? _lastPosition;

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
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      _lastPosition = position;
      if (kDebugMode) {
        print('📍 Location: ${position.latitude}, ${position.longitude}');
      }
      return position;
    } catch (e) {
      if (kDebugMode) print('📍 Failed to get location: $e');
      return null;
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
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;

      final p = placemarks.first;
      return PlacemarkAddress(
        street: [p.street, p.subLocality]
            .where((s) => s != null && s.isNotEmpty)
            .join(', '),
        city: p.locality ?? '',
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
