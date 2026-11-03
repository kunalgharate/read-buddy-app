import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:read_buddy_app/core/services/location_service.dart';

const MethodChannel _geoChannel =
    MethodChannel('flutter.baseflow.com/geolocator');

void _mockGeo(
  Future<Object?> Function(MethodCall call) handler,
) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_geoChannel, handler);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_geoChannel, null);
  });

  // Runs first: a successful fix is cached for a short time, so the
  // "location off" case must be exercised before any position is cached.
  test('returns null when device location is turned off', () async {
    _mockGeo((call) async {
      if (call.method == 'isLocationServiceEnabled') return false;
      return null;
    });

    final position = await LocationService.instance.getCurrentLocation();

    expect(position, isNull);
  });

  test('falls back to the last known fix when the live GPS times out',
      () async {
    _mockGeo((call) async {
      switch (call.method) {
        case 'isLocationServiceEnabled':
          return true;
        case 'checkPermission':
        case 'requestPermission':
          return 2; // whileInUse
        case 'getCurrentPosition':
          throw PlatformException(code: 'TIMEOUT', message: 'No GPS fix');
        case 'getLastKnownPosition':
          return {'latitude': 19.076, 'longitude': 72.8777};
        default:
          return null;
      }
    });

    final position = await LocationService.instance.getCurrentLocation();

    expect(position, isNotNull);
    expect(position!.latitude, closeTo(19.076, 0.0001));
    expect(position.longitude, closeTo(72.8777, 0.0001));
  });
}
