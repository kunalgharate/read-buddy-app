import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_constants.dart';

class ServerHealthCheck {
  static Future<bool> checkServerHealth() async {
    try {
      if (kDebugMode) {
        print('🏥 ServerHealthCheck: Checking server health...');
      }
      
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
      
      // Try to ping a simple endpoint or the base URL
      final response = await dio.get('${ApiConstants.baseUrl}/health');
      
      if (kDebugMode) {
        print('🏥 ServerHealthCheck: Server responded with status: ${response.statusCode}');
      }
      
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('🏥 ServerHealthCheck: Server health check failed: $e');
      }
      return false;
    }
  }
  
  static Future<void> wakeUpServer() async {
    try {
      if (kDebugMode) {
        print('⏰ ServerHealthCheck: Attempting to wake up server...');
      }
      
      final dio = Dio();
      dio.options.connectTimeout = const Duration(seconds: 120); // Long timeout for cold start
      dio.options.receiveTimeout = const Duration(seconds: 120);
      
      // Make a simple request to wake up the server
      await dio.get(ApiConstants.baseUrl);
      
      if (kDebugMode) {
        print('⏰ ServerHealthCheck: Server wake-up request completed');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⏰ ServerHealthCheck: Server wake-up failed: $e');
      }
    }
  }
}
