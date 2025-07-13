import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Required for DefaultHttpClientAdapter
import 'package:flutter/foundation.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio();

    // Add interceptors
    dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
      logPrint: (object) {
        if (kDebugMode) {
          print('🌐 API LOG: $object');
        }
      },
    ));

    // Add custom interceptor for more detailed logging
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          print('🚀 REQUEST[${options.method}] => PATH: ${options.path}');
          print('🚀 REQUEST HEADERS: ${options.headers}');
          print('🚀 REQUEST DATA: ${options.data}');
          print('🚀 REQUEST QUERY PARAMS: ${options.queryParameters}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('✅ RESPONSE DATA: ${response.data}');
          print('✅ RESPONSE HEADERS: ${response.headers}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print(
              '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('❌ ERROR MESSAGE: ${error.message}');
          print('❌ ERROR RESPONSE: ${error.response?.data}');
          print('❌ ERROR TYPE: ${error.type}');
          print('❌ ERROR STACK TRACE: ${error.stackTrace}');
        }
        handler.next(error);
      },
    ));

    // Set longer timeout for slow servers (like Render.com free tier)
    dio.options.connectTimeout = const Duration(seconds: 120);
    dio.options.receiveTimeout = const Duration(seconds: 180);
    dio.options.sendTimeout = const Duration(seconds: 120);

    // Set default headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'ReadBuddyApp/1.0.0',
    };

    // Add retry interceptor
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          if (kDebugMode) {
            print('🔄 Retrying request due to timeout...');
          }

          try {
            final response = await dio.request(
              error.requestOptions.path,
              data: error.requestOptions.data,
              queryParameters: error.requestOptions.queryParameters,
              options: Options(
                method: error.requestOptions.method,
                headers: error.requestOptions.headers,
              ),
            );
            handler.resolve(response);
            return;
          } catch (retryError) {
            if (kDebugMode) {
              print('🔄 Retry failed: $retryError');
            }
          }
        }
        handler.next(error);
      },
    ));

    //Accept self-signed/invalid certs in development (fixes HandshakeException)
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback = (cert, host, port) {
        if (kDebugMode) {
          print('⚠️ Accepting bad certificate from $host:$port');
        }
        return true;
      };
      return client;
    };

    return dio;
  }
}
