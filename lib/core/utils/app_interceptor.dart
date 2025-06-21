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

class AppInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;
  final Dio authDio; // clean Dio, no interceptors

  AppInterceptor(this.secureStorage, this.authDio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await secureStorage.read(key: 'accessToken');
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isUnauthorized = err.response?.statusCode == 403;
    final isRefreshCall = err.requestOptions.uri.path.endsWith('/auth/refresh');

    if (isUnauthorized && !isRefreshCall) {
      final refreshToken = await secureStorage.read(key: 'refreshToken');
      if (refreshToken != null) {
        try {
          final refreshResponse = await authDio.post(
            'https://readbuddy-server.onrender.com/api/auth/refresh',
            options: Options(
              headers: {
                'Authorization': 'Bearer $refreshToken',
              },
            ),
          );

          final newAccessToken = refreshResponse.data['accessToken'];
          final newRefreshToken = refreshResponse.data['refreshToken'];

          await secureStorage.write(key: 'accessToken', value: newAccessToken);
          await secureStorage.write(key: 'refreshToken', value: newRefreshToken);

          // Retry original request with updated access token
          final retryRequest = err.requestOptions;
          retryRequest.headers['Authorization'] = 'Bearer $newAccessToken';

          final retryResponse = await Dio().fetch(retryRequest);
          return handler.resolve(retryResponse);
        } catch (e) {
          await secureStorage.deleteAll();
          // TODO: Redirect to login or handle logout
        }
      }
    }

    handler.next(err);
  }
}
