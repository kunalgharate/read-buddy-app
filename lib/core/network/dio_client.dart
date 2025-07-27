import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // Required for DefaultHttpClientAdapter
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

    // Add token refresh interceptor
    dio.interceptors.add(TokenRefreshInterceptor(dio));

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
      print('🔐 Request Headers: ${err.requestOptions.headers}');
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
        
        if (kDebugMode) {
          print('🔐 TokenRefresh: Starting token refresh process');
        }
        
        // Attempt to refresh the token
        final refreshSuccess = await _refreshToken();
        
        if (refreshSuccess) {
          if (kDebugMode) {
            print('🔐 TokenRefresh: Token refreshed successfully, retrying original request');
          }
          
          // Retry the original request
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          
          // Process queued requests
          await _processQueuedRequests();
        } else {
          if (kDebugMode) {
            print('🔐 TokenRefresh: Token refresh failed, clearing session');
          }
          
          // Clear user session and redirect to login
          await _handleRefreshFailure();
          handler.next(err);
        }
      } catch (refreshError) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Exception during token refresh');
          print('🔐 Error: $refreshError');
          print('🔐 Stack trace: ${refreshError is Error ? refreshError.stackTrace : 'No stack trace'}');
        }
        
        await _handleRefreshFailure();
        handler.next(err);
      } finally {
        _isRefreshing = false;
        _failedQueue.clear();
      }
    } else {
      // Not a token error, pass through
      if (kDebugMode) {
        print('🔐 TokenRefresh: Not a token error, passing through');
      }
      handler.next(err);
    }
  }

  /// Checks if the error is related to token expiration/invalidity
  bool _isTokenError(DioException err) {
    final statusCode = err.response?.statusCode;
    final responseData = err.response?.data;
    
    if (kDebugMode) {
      print('🔐 TokenRefresh: Checking if token error - Status: $statusCode');
      print('🔐 TokenRefresh: Response data: $responseData');
    }
    
    // Check for 401 Unauthorized
    if (statusCode == 401) {
      if (kDebugMode) {
        print('🔐 TokenRefresh: 401 Unauthorized detected');
      }
      return true;
    }
    
    // Check for 403 with token-related error message
    if (statusCode == 403) {
      if (responseData is Map<String, dynamic>) {
        final error = responseData['error']?.toString().toLowerCase() ?? '';
        final message = responseData['message']?.toString().toLowerCase() ?? '';
        
        // Check for your specific error message: "Invalid or expired token"
        final isTokenError = error.contains('token') || 
                            error.contains('expired') || 
                            error.contains('invalid') ||
                            message.contains('token') || 
                            message.contains('expired') || 
                            message.contains('invalid') ||
                            error == 'invalid or expired token' ||
                            message == 'invalid or expired token';
        
        if (kDebugMode) {
          print('🔐 TokenRefresh: 403 Forbidden - Is token error: $isTokenError');
          print('🔐 TokenRefresh: Error message: "$error"');
          print('🔐 TokenRefresh: Message: "$message"');
        }
        
        return isTokenError;
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

      if (kDebugMode) {
        print('🔐 TokenRefresh: Using refresh token: ${refreshToken.substring(0, 20)}...');
        print('🔐 TokenRefresh: Refresh token length: ${refreshToken.length}');
      }

      // Create a new Dio instance to avoid interceptor loops
      final refreshDio = Dio();
      refreshDio.options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'ReadBuddyApp/1.0.0',
      };

      // Set timeouts
      refreshDio.options.connectTimeout = const Duration(seconds: 30);
      refreshDio.options.receiveTimeout = const Duration(seconds: 30);
      refreshDio.options.sendTimeout = const Duration(seconds: 30);

      // Use the correct endpoint
      final endpoint = '${ApiConstants.baseUrl}/users/refresh-token';

      // Try first approach: refresh token in request body
      try {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Trying endpoint: $endpoint');
          print('🔐 TokenRefresh: Approach 1 - Sending refresh token in request body');
        }

        final requestData = {'refreshToken': refreshToken};
        if (kDebugMode) {
          print('🔐 TokenRefresh: Request data: $requestData');
        }

        final response = await refreshDio.post(
          endpoint,
          data: requestData,
        );

        if (kDebugMode) {
          print('🔐 TokenRefresh: Response status: ${response.statusCode}');
          print('🔐 TokenRefresh: Response data: ${response.data}');
        }

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data as Map<String, dynamic>;
          final newAccessToken = data['accessToken'] as String?;
          final newRefreshToken = data['refreshToken'] as String?;

          if (newAccessToken != null) {
            // Save new tokens using SecureStorageUtil
            await getIt<SecureStorageUtil>().saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
            );

            if (kDebugMode) {
              print('🔐 TokenRefresh: New tokens saved successfully');
              print('🔐 TokenRefresh: New access token: ${newAccessToken.substring(0, 20)}...');
              if (newRefreshToken != null) {
                print('🔐 TokenRefresh: New refresh token: ${newRefreshToken.substring(0, 20)}...');
              }
            }
            return true;
          } else {
            if (kDebugMode) {
              print('🔐 TokenRefresh: No access token in response');
            }
          }
        } else {
          if (kDebugMode) {
            print('🔐 TokenRefresh: Invalid response status or data');
          }
        }
      } catch (bodyError) {
        if (kDebugMode) {
          print('🔐 TokenRefresh: Body approach failed: $bodyError');
          if (bodyError is DioException) {
            print('🔐 TokenRefresh: Status code: ${bodyError.response?.statusCode}');
            print('🔐 TokenRefresh: Response: ${bodyError.response?.data}');
          }
        }

        // If body approach failed with "Token required", try Authorization header approach
        if (bodyError is DioException && 
            bodyError.response?.statusCode == 401 &&
            bodyError.response?.data?.toString().contains('Token required') == true) {
          
          try {
            if (kDebugMode) {
              print('🔐 TokenRefresh: Approach 2 - Trying with Authorization header');
            }

            // Try with Authorization header
            final headerResponse = await refreshDio.post(
              endpoint,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $refreshToken',
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                  'User-Agent': 'ReadBuddyApp/1.0.0',
                },
              ),
            );

            if (kDebugMode) {
              print('🔐 TokenRefresh: Header approach - Response status: ${headerResponse.statusCode}');
              print('🔐 TokenRefresh: Header approach - Response data: ${headerResponse.data}');
            }

            if (headerResponse.statusCode == 200 && headerResponse.data != null) {
              final data = headerResponse.data as Map<String, dynamic>;
              final newAccessToken = data['accessToken'] as String?;
              final newRefreshToken = data['refreshToken'] as String?;

              if (newAccessToken != null) {
                // Save new tokens using SecureStorageUtil
                await getIt<SecureStorageUtil>().saveTokens(
                  accessToken: newAccessToken,
                  refreshToken: newRefreshToken ?? refreshToken,
                );

                if (kDebugMode) {
                  print('🔐 TokenRefresh: Header approach - New tokens saved successfully');
                  print('🔐 TokenRefresh: Header approach - New access token: ${newAccessToken.substring(0, 20)}...');
                }
                return true;
              }
            }
          } catch (headerError) {
            if (kDebugMode) {
              print('🔐 TokenRefresh: Header approach also failed: $headerError');
              if (headerError is DioException) {
                print('🔐 TokenRefresh: Header Status code: ${headerError.response?.statusCode}');
                print('🔐 TokenRefresh: Header Response: ${headerError.response?.data}');
              }
            }
          }
        }
        
        return false;
      }

      if (kDebugMode) {
        print('🔐 TokenRefresh: Token refresh failed - no valid response');
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
