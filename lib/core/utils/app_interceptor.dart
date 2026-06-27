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

class AppInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _authDio;

  // Prevents multiple concurrent refresh attempts
  bool _isRefreshing = false;
  Completer<String?>? _refreshCompleter;

  AppInterceptor(this._secureStorage, this._authDio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
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
        debugPrint('🔄 Token expired. Attempting refresh...');
        final newAccessToken = await _getOrRefreshToken();
        if (newAccessToken != null) {
          debugPrint('✅ Token refreshed successfully');
          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          return handler.resolve(retryResponse);
        }
      } catch (refreshError) {
        debugPrint('❌ Token refresh failed: $refreshError');
        await _handleRefreshFailure();
      }
    }
    handler.next(err);
  }

  /// Ensures only one refresh happens at a time. Concurrent 401s wait for
  /// the same refresh result instead of firing multiple refresh calls.
  Future<String?> _getOrRefreshToken() async {
    if (_isRefreshing) {
      debugPrint('🔄 Refresh already in progress, waiting...');
      return _refreshCompleter!.future;
    }
    _isRefreshing = true;
    _refreshCompleter = Completer<String?>();
    try {
      final token = await _refreshAccessToken();
      _refreshCompleter!.complete(token);
      return token;
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _isRefreshing = false;
    }
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
      // TOKEN_EXPIRED or any other 401 → attempt refresh
      return true;
    }

    if (status == ApiConstants.unauthorized) {
      return true;
    }
    if (status == ApiConstants.notFound &&
        (path.contains('/accept') || path.contains('/decline'))) {
      return true;
    }
    return false;
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      debugPrint('❌ No refresh token in storage');
      throw Exception('No refresh token available');
    }

    debugPrint('🔄 Calling refresh endpoint: ${ApiConstants.refreshToken}');

    final response = await _authDio.post(
      ApiConstants.refreshToken,
      data: {'token': refreshToken},
      options: Options(
        headers: {'Content-Type': 'application/json'},
      ),
    );

    debugPrint('🔄 Refresh response status: ${response.statusCode}');
    debugPrint('🔄 Refresh response data: ${response.data}');

    if (response.statusCode == ApiConstants.success) {
      final newAccessToken = response.data['accessToken'];
      await _secureStorage.write(key: 'accessToken', value: newAccessToken);
      return newAccessToken;
    }

    throw Exception('Token refresh failed with status: ${response.statusCode}');
  }

  Future<Response> _retryRequest(
      RequestOptions options, String newAccessToken) async {
    options.headers['Authorization'] = 'Bearer $newAccessToken';
    return await _authDio.fetch(options);
  }

  Future<void> _handleRefreshFailure() async {
    await _secureStorage.deleteAll();
    // Note: Navigation should be handled at the UI level through BLoC events
  }
}
