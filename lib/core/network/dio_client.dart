import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_interceptor.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio();
    final authDio = Dio();
    dio.interceptors.add(AppInterceptor(const FlutterSecureStorage(), authDio));

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
    // Increased timeouts for release builds and cold server starts
    dio.options.connectTimeout =
        const Duration(seconds: 120); // Increased from 60s
    dio.options.receiveTimeout =
        const Duration(seconds: 180); // Increased from 90s
    dio.options.sendTimeout =
        const Duration(seconds: 120); // Increased from 60s

    // Set default headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'ReadBuddyApp/1.0.0',
    };

    // Add retry interceptor for better reliability
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          if (kDebugMode) {
            print('🔄 Retrying request due to timeout...');
          }

          // Retry once for timeout errors
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

    return dio;
  }
}
