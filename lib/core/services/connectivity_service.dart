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

  /// Actual DNS lookup to confirm internet works.
  Future<bool> _verifyInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
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
