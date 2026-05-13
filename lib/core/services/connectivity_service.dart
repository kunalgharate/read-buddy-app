import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Global connectivity service that monitors network state in real-time.
/// Use [instance] singleton across the app.
class ConnectivityService {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  final _controller = StreamController<bool>.broadcast();

  /// Stream that emits `true` when online, `false` when offline.
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Start as null so the first check always emits.
  bool? _isConnected;

  /// Current connectivity state. Returns false if not yet checked.
  bool get isConnected => _isConnected ?? false;

  /// Start listening. Call once from main().
  Future<void> init() async {
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleChange,
    );
    // Do the first check synchronously before app renders
    await checkNow();
  }

  Future<void> _handleChange(List<ConnectivityResult> results) async {
    final hasNetwork = results.any(
      (r) => r != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      _update(false);
      return;
    }

    // Has network adapter, but verify actual internet
    final hasInternet = await _verifyInternet();
    _update(hasInternet);
  }

  /// Force a connectivity check right now.
  Future<bool> checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasNetwork = results.any(
        (r) => r != ConnectivityResult.none,
      );

      if (!hasNetwork) {
        _update(false);
        return false;
      }

      final hasInternet = await _verifyInternet();
      _update(hasInternet);
      return hasInternet;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 ConnectivityService: check failed — $e');
      }
      _update(false);
      return false;
    }
  }

  /// Actual internet verification using multiple strategies.
  /// On emulators, DNS lookup can be unreliable, so we try multiple approaches.
  Future<bool> _verifyInternet() async {
    // Strategy 1: DNS lookup with multiple hosts
    final hosts = ['google.com', 'cloudflare.com', '1.1.1.1'];
    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // Try next host
      }
    }

    // Strategy 2: Try a raw socket connection to a known IP (bypasses DNS)
    try {
      final socket = await Socket.connect(
        '1.1.1.1', // Cloudflare DNS - always available
        53, // DNS port
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (_) {
      // Socket connection failed
    }

    // Strategy 3: On emulators, connectivity_plus may report correctly
    // but DNS fails. If we have a network adapter, assume connected
    // and let actual API calls handle failures gracefully.
    if (kDebugMode) {
      try {
        final results = await _connectivity.checkConnectivity();
        final hasAdapter = results.any(
          (r) => r == ConnectivityResult.wifi || r == ConnectivityResult.mobile,
        );
        if (hasAdapter) {
          print(
              '🌐 ConnectivityService: DNS failed but network adapter present — assuming connected (emulator workaround)');
          return true;
        }
      } catch (_) {}
    }

    return false;
  }

  void _update(bool connected) {
    final changed = _isConnected != connected;
    _isConnected = connected;
    // Always emit on first check (_isConnected was null) or on change
    if (changed) {
      _controller.add(connected);
      if (kDebugMode) {
        print(
          '🌐 ConnectivityService: ${connected ? "ONLINE" : "OFFLINE"}',
        );
      }
    }
  }

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
