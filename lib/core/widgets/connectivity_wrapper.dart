import 'dart:async';

import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';
import 'no_internet_dialog.dart';

/// Wrap this around your MaterialApp's home to automatically
/// show/hide the no-internet dialog globally on any screen.
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with WidgetsBindingObserver {
  late StreamSubscription<bool> _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _sub = ConnectivityService.instance.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Show immediately if already offline (init() completed before build)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ConnectivityService.instance.isConnected) {
        NoInternetDialog.show(context);
      }
    });
  }

  /// Re-check when app comes back to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ConnectivityService.instance.checkNow();
    }
  }

  void _onConnectivityChanged(bool isConnected) {
    if (!mounted) return;
    if (!isConnected) {
      NoInternetDialog.show(context);
    } else {
      NoInternetDialog.dismiss(context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
