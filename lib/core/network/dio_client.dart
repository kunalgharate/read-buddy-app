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
    dio.interceptors.add(
      LogInterceptor(
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
      ),
    );

    // Add custom interceptor for more detailed logging
    dio.interceptors.add(
      InterceptorsWrapper(
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
              '✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
            );
            print('✅ RESPONSE DATA: ${response.data}');
            print('✅ RESPONSE HEADERS: ${response.headers}');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            print(
              '❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
            );
            print('❌ ERROR MESSAGE: ${error.message}');
            print('❌ ERROR RESPONSE: ${error.response?.data}');
            print('❌ ERROR TYPE: ${error.type}');
            print('❌ ERROR STACK TRACE: ${error.stackTrace}');
          }
          handler.next(error);
        },
      ),
    );

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

    // Retry interceptor for timeout, TLS and dropped connections.
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) async {
          final isTimeout = error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout;

          // The Render/Cloudflare edge sometimes drops pooled keep-alive
          // connections ("Connection reset by peer"), which surfaces as a
          // DioExceptionType.unknown with no response. Only retry idempotent
          // requests so a retry can never create a duplicate record.
          final isIdempotent = error.requestOptions.method == 'GET' ||
              error.requestOptions.method == 'HEAD';
          final isDroppedConnection =
              isIdempotent && _isDroppedConnection(error);

          final shouldRetry =
              isTimeout || _isTlsError(error) || isDroppedConnection;

          if (shouldRetry) {
            // Timeouts/TLS get one retry, dropped connections two with a
            // short backoff so a half-closed socket has time to clear.
            final maxRetries = isDroppedConnection ? 2 : 1;
            final retryCount =
                (error.requestOptions.extra['_retryCount'] as num?)?.toInt() ??
                    0;
            if (retryCount < maxRetries) {
              if (kDebugMode) {
                print(
                  '🔄 Retrying request due to ${_retryReason(error)} '
                  '(${retryCount + 1}/$maxRetries)...',
                );
              }

              try {
                if (isDroppedConnection) {
                  await Future.delayed(
                    Duration(milliseconds: 300 * (retryCount + 1)),
                  );
                }
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
      ),
    );

    return dio;
  }

  /// Check if the request never got a response because the socket was closed
  /// under us (stale keep-alive connection, edge proxy reset, etc.).
  static bool _isDroppedConnection(DioException error) {
    if (error.response != null) return false;
    final details = '${error.message ?? ''} ${error.error ?? ''}'.toLowerCase();
    return details.contains('connection reset') ||
        details.contains('connection closed') ||
        details.contains('connection terminated') ||
        details.contains('broken pipe') ||
        error.error is SocketException ||
        error.type == DioExceptionType.connectionError;
  }

  static String _retryReason(DioException error) {
    if (_isDroppedConnection(error)) return 'a dropped connection';
    if (_isTlsError(error)) return 'a TLS error';
    return 'a timeout';
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
