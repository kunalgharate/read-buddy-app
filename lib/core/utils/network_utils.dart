import 'dart:io';
import 'package:flutter/foundation.dart';

class NetworkUtils {
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to lookup a reliable host
      final result = await InternetAddress.lookup('google.com');
      
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (kDebugMode) {
          print('🌐 NetworkUtils: Internet connection available');
        }
        return true;
      }
      
      if (kDebugMode) {
        print('🌐 NetworkUtils: No internet connection');
      }
      return false;
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('🌐 NetworkUtils: Socket exception - $e');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('🌐 NetworkUtils: Unexpected error checking connectivity - $e');
      }
      return false;
    }
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
    
    final canReachReadBuddyServer = await canReachServer('readbuddy-server.onrender.com');
    
    if (!canReachReadBuddyServer) {
      return 'Unable to connect to ReadBuddy server. Please try again later.';
    }
    
    return 'Network error occurred. Please try again.';
  }
}
