import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/secure_storage_utils.dart';
import '../di/injection.dart';
import 'api_constants.dart';

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
          print('✅ RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          print('✅ RESPONSE DATA: ${response.data}');
          print('✅ RESPONSE HEADERS: ${response.headers}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('❌ ERROR MESSAGE: ${error.message}');
          print('❌ ERROR RESPONSE: ${error.response?.data}');
          print('❌ ERROR TYPE: ${error.type}');
          print('❌ ERROR STACK TRACE: ${error.stackTrace}');
        }
        handler.next(error);
      },
    ));

    // Add token refresh interceptor
    dio.interceptors.add(TokenRefreshInterceptor(dio));

    // Set longer timeout for slow servers (like Render.com free tier)
    // Increased timeouts for release builds and cold server starts
    dio.options.connectTimeout = const Duration(seconds: 120); // Increased from 60s
    dio.options.receiveTimeout = const Duration(seconds: 180); // Increased from 90s
    dio.options.sendTimeout = const Duration(seconds: 120);    // Increased from 60s

    // Set default headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'ReadBuddyApp/1.0.0',
    };

    // Add retry interceptor for better reliability
    dio.interceptors.add(InterceptorsWrapper(
      onError: (error, handler) async {
        // Don't retry auth errors (they should be handled by token refresh interceptor)
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          handler.next(error);
          return;
        }

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

/// Token refresh interceptor for automatic token renewal
class TokenRefreshInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  final List<RequestOptions> _failedQueue = [];

  TokenRefreshInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add token to all requests (except auth endpoints)
    if (!_isAuthEndpoint(options.path)) {
      final token = await getIt<SecureStorageUtil>().getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        
        if (kDebugMode) {
          print('🔐 TokenRefresh: Added token to request');
          print('🔐 Path: ${options.path}');
        }
      }
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (kDebugMode) {
      print('🔐 TokenRefresh: Error intercepted');
      print('🔐 Status Code: ${err.response?.statusCode}');
      print('🔐 Path: ${err.requestOptions.path}');
      print('🔐 Response: ${err.response?.data}');
    }

    // Check if it's a token-related error (401 or 403 with token error)
    if (_isTokenError(err)) {
      if (kDebugMode) {
        print('🔐 TokenRefresh: Token error detected, attempting refresh');
      }

      // Don't try to refresh token for auth endpoints
      if (_isAuthEndpoint(err.requestOptions.path)) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Auth endpoint error, not refreshing');
        }
        handler.next(err);
        return;
      }

      // If we're already refreshing, queue this request
      if (_isRefreshing) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Already refreshing, queueing request');
        }
        _failedQueue.add(err.requestOptions);
        return;
      }

      try {
        _isRefreshing = true;
        
        // Attempt to refresh the token
        final refreshSuccess = await _refreshToken();
        
        if (refreshSuccess) {
          if (kDebugMode) {
            print('🔐 TokenRefresh: Token refreshed successfully');
          }
          
          // Retry the original request
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          
          // Process queued requests
          await _processQueuedRequests();
        } else {
          if (kDebugMode) {
            print('🔐 TokenRefresh: Token refresh failed');
          }
          
          // Clear user session and redirect to login
          await _handleRefreshFailure();
          handler.next(err);
        }
      } catch (refreshError) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Exception during token refresh');
          print('🔐 Error: $refreshError');
        }
        
        await _handleRefreshFailure();
        handler.next(err);
      } finally {
        _isRefreshing = false;
        _failedQueue.clear();
      }
    } else {
      // Not a token error, pass through
      handler.next(err);
    }
  }

  /// Checks if the error is related to token expiration/invalidity
  bool _isTokenError(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    
    // Check for 401 Unauthorized
    if (statusCode == 401) {
      return true;
    }
    
    // Check for 403 with token-related error message
    if (statusCode == 403) {
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error']?.toString().toLowerCase() ?? '';
        final message = responseData['message']?.toString().toLowerCase() ?? '';
        
        return error.contains('token') || 
               error.contains('expired') || 
               error.contains('invalid') ||
               message.contains('token') || 
               message.contains('expired') || 
               message.contains('invalid');
      }
    }
    
    return false;
  }

  /// Checks if the endpoint is an authentication endpoint
  bool _isAuthEndpoint(String path) {
    final authPaths = [
      '/login',
      '/register',
      '/verify-email',
      '/forgot-password',
      '/reset-password',
      '/refresh-token',
      '/google-auth',
    ];
    
    return authPaths.any((authPath) => path.contains(authPath));
  }

  /// Attempts to refresh the access token
  Future<bool> _refreshToken() async {
    try {
      if (kDebugMode) {
        print('🔐 TokenRefresh: Starting token refresh');
      }

      final refreshToken = await getIt<SecureStorageUtil>().getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: No refresh token available');
        }
        return false;
      }

      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio();
      refreshDio.options.baseUrl = ApiConstants.baseUrl;
      refreshDio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final response = await refreshDio.post(
        '/auth/refresh-token', // You'll need to add this endpoint to your server
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final newAccessToken = data['accessToken'] as String?;
        final newRefreshToken = data['refreshToken'] as String?;

        if (newAccessToken != null) {
          // Save new tokens
          await getIt<SecureStorageUtil>().saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken ?? refreshToken,
          );

          if (kDebugMode) {
            print('🔐 TokenRefresh: New tokens saved');
          }
          return true;
        }
      }

      if (kDebugMode) {
        print('🔐 TokenRefresh: Invalid refresh response');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('🔐 TokenRefresh: Refresh token error: $e');
      }
      return false;
    }
  }

  /// Retries the original request with the new token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    if (kDebugMode) {
      print('🔐 TokenRefresh: Retrying original request');
      print('🔐 Method: ${requestOptions.method}');
      print('🔐 Path: ${requestOptions.path}');
    }

    // Get the new token and add it to headers
    final newToken = await getIt<SecureStorageUtil>().getAccessToken();
    if (newToken != null) {
      requestOptions.headers['Authorization'] = 'Bearer $newToken';
    }

    // Retry the request
    return await _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        persistentConnection: requestOptions.persistentConnection,
        requestEncoder: requestOptions.requestEncoder,
        responseDecoder: requestOptions.responseDecoder,
        listFormat: requestOptions.listFormat,
      ),
    );
  }

  /// Processes queued requests after successful token refresh
  Future<void> _processQueuedRequests() async {
    if (_failedQueue.isEmpty) return;

    if (kDebugMode) {
      print('🔐 TokenRefresh: Processing ${_failedQueue.length} queued requests');
    }

    final queueCopy = List<RequestOptions>.from(_failedQueue);
    _failedQueue.clear();

    for (final requestOptions in queueCopy) {
      try {
        await _retryRequest(requestOptions);
        if (kDebugMode) {
          print('🔐 TokenRefresh: Queued request succeeded: ${requestOptions.path}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Queued request failed: ${requestOptions.path}, Error: $e');
        }
      }
    }
  }

  /// Handles refresh token failure by clearing user session
  Future<void> _handleRefreshFailure() async {
    if (kDebugMode) {
      print('🔐 TokenRefresh: Handling refresh failure - clearing session');
    }

    try {
      // Clear all user data
      await getIt<SecureStorageUtil>().clearTokens();
      await getIt<SecureStorageUtil>().clearUser();
      
      // TODO: Navigate to login screen
      // You might want to use a navigation service or event bus here
      
    } catch (e) {
      if (kDebugMode) {
        print('🔐 TokenRefresh: Error clearing session: $e');
      }
    }
  }
}
