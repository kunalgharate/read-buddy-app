import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import '../widgets/no_internet_dialog.dart';

/// Mixin for StatefulWidgets that need to check connectivity
/// before performing network-dependent actions.
///
/// Usage:
/// ```dart
/// class _MyPageState extends State<MyPage> with ConnectivityMixin {
///   void _loadData() {
///     if (!requireConnectivity()) return;
///     // proceed with network call...
///   }
/// }
/// ```
mixin ConnectivityMixin<T extends StatefulWidget> on State<T> {
  /// Returns true if connected. Shows dialog and returns false if not.
  bool requireConnectivity() {
    if (ConnectivityService.instance.isConnected) return true;
    NoInternetDialog.show(context);
    return false;
  }

  /// Async version — does a fresh check before proceeding.
  Future<bool> requireConnectivityAsync() async {
    final connected = await ConnectivityService.instance.checkNow();
    if (!connected && mounted) {
      NoInternetDialog.show(context);
    }
    return connected;
  }
}
