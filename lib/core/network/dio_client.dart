import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/app_interceptor.dart';

class DioClient {
  static Dio createDio() {
    final dio = Dio();
    final authDio = Dio();
    dio.interceptors.add(AppInterceptor(const FlutterSecureStorage(), authDio));

    // Configure HTTP client adapter to handle TLS issues with large uploads
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Allow longer idle timeouts for large file uploads
        client.idleTimeout = const Duration(seconds: 120);
        // Disable session cache to prevent TLS MAC errors on chunked uploads
        client.maxConnectionsPerHost = 5;
        return client;
      },
    );

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

    // Retry interceptor for timeout and TLS errors
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        final shouldRetry = error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout ||
            _isTlsError(error);

        if (shouldRetry) {
          // Only retry once — check if we already retried
          final retryCount = error.requestOptions.extra['_retryCount'] ?? 0;
          if (retryCount < 1) {
            if (kDebugMode) {
              print(
                  '🔄 Retrying request due to ${_isTlsError(error) ? "TLS error" : "timeout"}...');
            }

            try {
              error.requestOptions.extra['_retryCount'] = retryCount + 1;
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              if (kDebugMode) {
                print('🔄 Retry failed: $retryError');
              }
            }
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }

  /// Check if error is a TLS/SSL handshake error
  static bool _isTlsError(DioException error) {
    if (error.type != DioExceptionType.unknown) return false;
    final errorStr = error.error?.toString() ?? '';
    return errorStr.contains('TlsException') ||
        errorStr.contains('SSLV3_ALERT') ||
        errorStr.contains('BAD_RECORD_MAC') ||
        errorStr.contains('HandshakeException');
  }
}
