// import 'package:dio/dio.dart';
//
// class AppInterceptor extends Interceptor {
//   @override
//   void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
//     print('[DIO Request] => ${options.method} ${options.uri}');
//     print('Headers: ${options.headers}');
//     print('Data: ${options.data}');
//     handler.next(options); // continue
//   }
//
//   @override
//   void onResponse(Response response, ResponseInterceptorHandler handler) {
//     print('[DIO Response] => ${response.statusCode} ${response.requestOptions.uri}');
//     print('Response data: ${response.data}');
//     handler.next(response); // continue
//   }
//
//   @override
//   void onError(DioException err, ErrorInterceptorHandler handler) {
//     print('[DIO Error] => ${err.type} ${err.message}');
//     if (err.response != null) {
//       print('Error response: ${err.response?.data}');
//     }
//     handler.next(err); // continue
//   }
// }

import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/services/session_event_bus.dart';

class AppInterceptor extends QueuedInterceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _authDio;

  AppInterceptor(this._secureStorage, this._authDio) {
    _authDio.options.connectTimeout = const Duration(seconds: 30);
    _authDio.options.receiveTimeout = const Duration(seconds: 30);
    _authDio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      if (!options.headers.containsKey('Content-Type') &&
          options.data is! FormData) {
        options.headers['Content-Type'] = 'application/json';
      }
      options.headers['Accept'] = 'application/json';
    } catch (e) {
      // Continue without token if storage fails
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldAttemptTokenRefresh(err)) {
      try {
        if (kDebugMode) {
          print('🔄 Token expired. Attempting refresh...');
        }
        final newAccessToken = await _refreshAccessToken();
        if (newAccessToken != null) {
          if (kDebugMode) {
            print('✅ Token refreshed successfully');
          }
          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          return handler.resolve(retryResponse);
        }
      } catch (refreshError) {
        if (kDebugMode) {
          print('❌ Token refresh failed: $refreshError');
        }
        await _handleRefreshFailure();
      }
    }
    handler.next(err);
  }

  bool _shouldAttemptTokenRefresh(DioException err) {
    final status = err.response?.statusCode;
    final path = err.requestOptions.uri.path;
    final isAuthRoute = path.contains('/refresh-token') ||
        path.contains('/login') ||
        path.contains('/register');
    if (isAuthRoute) return false;

    final responseData = err.response?.data;
    if (status == 401 && responseData is Map) {
      final code = responseData['code'];
      if (code == 'SESSION_REPLACED') {
        SessionEventBus.instance.fire(SessionEvent.sessionReplaced);
        return false;
      }
      return true;
    }

    if (status == 401) return true;

    return false;
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      if (kDebugMode) {
        print('❌ No refresh token in storage');
      }
      throw Exception('No refresh token available');
    }

    if (kDebugMode) {
      print('🔄 Calling refresh endpoint: ${ApiConstants.refreshToken}');
    }

    final response = await _authDio.post(
      ApiConstants.refreshToken,
      data: {'token': refreshToken},
    );

    if (kDebugMode) {
      print('🔄 Refresh response status: ${response.statusCode}');
    }

    if (response.statusCode == 200) {
      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];
      await _secureStorage.write(key: 'accessToken', value: newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
      }
      return newAccessToken;
    }

    throw Exception('Token refresh failed with status: ${response.statusCode}');
  }

  Future<Response> _retryRequest(
    RequestOptions options,
    String newAccessToken,
  ) async {
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    return await _authDio.fetch(options);
  }

  Future<void> _handleRefreshFailure() async {
    await _secureStorage.delete(key: 'accessToken');
    SessionEventBus.instance.fire(SessionEvent.sessionReplaced);
  }
}
