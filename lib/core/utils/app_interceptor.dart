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

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/api_constants.dart';

class AppInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Dio _authDio;

  AppInterceptor(this._secureStorage, this._authDio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
      if (!options.headers.containsKey('Content-Type') && options.data is! FormData) {
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
        final newAccessToken = await _refreshAccessToken();
        if (newAccessToken != null) {
          // Retry the original request with new token
          final retryResponse =
              await _retryRequest(err.requestOptions, newAccessToken);
          return handler.resolve(retryResponse);
        }
      } catch (refreshError) {
        await _handleRefreshFailure();
      }
    }
    handler.next(err);
  }

  bool _shouldAttemptTokenRefresh(DioException err) {
    return err.response?.statusCode == ApiConstants.unauthorized &&
        !err.requestOptions.uri.path.contains('/auth/refresh') &&
        !err.requestOptions.uri.path.contains('/login') &&
        !err.requestOptions.uri.path.contains('/register');
  }

  Future<String?> _refreshAccessToken() async {
    final refreshToken = await _secureStorage.read(key: 'refreshToken');
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final response = await _authDio.post(
      ApiConstants.refreshToken,
      options: Options(
        headers: {'Authorization': 'Bearer $refreshToken'},
      ),
    );

    if (response.statusCode == ApiConstants.success) {
      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await _secureStorage.write(key: 'accessToken', value: newAccessToken);
      if (newRefreshToken != null) {
        await _secureStorage.write(key: 'refreshToken', value: newRefreshToken);
      }

      return newAccessToken;
    }

    throw Exception('Token refresh failed');
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
