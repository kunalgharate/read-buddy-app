import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  /// Check if device has internet connectivity.
  /// Uses multiple strategies to handle emulator DNS issues.
  static Future<bool> hasInternetConnection() async {
    // Strategy 1: DNS lookup with multiple hosts
    final hosts = ['google.com', 'cloudflare.com', '1.1.1.1'];
    for (final host in hosts) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 3));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (kDebugMode) {
            print('🌐 NetworkUtils: Internet connection available (via $host)');
          }
          return true;
        }
      } catch (_) {
        // Try next host
      }
    }

    // Strategy 2: Raw socket connection (bypasses DNS)
    try {
      final socket = await Socket.connect(
        '1.1.1.1',
        53,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      if (kDebugMode) {
        print('🌐 NetworkUtils: Internet connection available (via socket)');
      }
      return true;
    } catch (_) {
      // Socket failed
    }

    if (kDebugMode) {
      print('🌐 NetworkUtils: No internet connection');
    }
    return false;
  }

  /// Check if specific server is reachable
  static Future<bool> canReachServer(String host) async {
    try {
      final result = await InternetAddress.lookup(host);

      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('🌐 NetworkUtils: Server $host is reachable');
        }
        return true;
      }

      if (kDebugMode) {
        print('🌐 NetworkUtils: Server $host is not reachable');
      }
      return false;
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('🌐 NetworkUtils: Cannot reach server $host - $e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 NetworkUtils: Error checking server $host - $e');
      }
      return false;
    }
  }

  /// Get network error message based on connectivity
  static Future<String> getNetworkErrorMessage() async {
    final hasInternet = await hasInternetConnection();

    if (!hasInternet) {
      return 'No internet connection. Please check your network settings.';
    }

    final canReachReadBuddyServer =
        await canReachServer('readbuddy-server.onrender.com');

    if (!canReachReadBuddyServer) {
      return 'Unable to connect to ReadBuddy server. Please try again later.';
    }

    return 'Network error occurred. Please try again.';
  }
}
