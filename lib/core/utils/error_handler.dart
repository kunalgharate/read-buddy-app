import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/api_constants.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (kDebugMode) {
      print('🚨 ErrorHandler: Processing error');
      print('🚨 ErrorHandler: Error type: ${error.runtimeType}');
      print('🚨 ErrorHandler: Error details: $error');
    }

    if (error is DioException) {
      return _handleDioError(error);
    }

    final message = error.toString();

    if (kDebugMode) {
      print('🚨 ErrorHandler: Final error message: $message');
    }

    return message;
  }

  static String _handleDioError(DioException error) {
    if (kDebugMode) {
      print('🚨 ErrorHandler: Handling Dio error');
      print('🚨 ErrorHandler: Status code: ${error.response?.statusCode}');
      print('🚨 ErrorHandler: Response data: ${error.response?.data}');
      print('🚨 ErrorHandler: Error type: ${error.type}');
      print('🚨 ErrorHandler: Error message: ${error.message}');
    }

    String message;

    switch (error.response?.statusCode) {
      case ApiConstants.badRequest:
        message = _extractErrorMessage(error.response?.data) ??
            'Invalid request. Please check your input.';
        break;

      case ApiConstants.unauthorized:
        message = _extractErrorMessage(error.response?.data) ??
            'Invalid credentials. Please check your email and password.';
        break;

      case ApiConstants.forbidden:
        message = _handleForbiddenError(error.response?.data);
        break;

      case ApiConstants.notFound:
        message = 'Resource not found.';
        break;

      case ApiConstants.conflict:
        message = _extractErrorMessage(error.response?.data) ??
            'This resource already exists.';
        break;

      case ApiConstants.internalServerError:
        message = 'Server error. Please try again later.';
        break;

      default:
        message = _handleNetworkError(error);
        break;
    }

    if (kDebugMode) {
      print('🚨 ErrorHandler: Processed error message: $message');
    }

    return message;
  }

  static String _handleNetworkError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. The server is taking too long to respond. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please check your connection and try again.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please check your connection and try again.';

      case DioExceptionType.connectionError:
        // More specific error message for connection issues
        if (error.message?.contains('SocketException') == true) {
          return 'Unable to connect to server. Please check your internet connection and try again.';
        } else if (error.message?.contains('HandshakeException') == true) {
          return 'Secure connection failed. Please try again.';
        } else if (error.message?.contains('HttpException') == true) {
          return 'Network error occurred. Please check your connection.';
        }
        return 'Connection failed. Please check your internet connection and try again.';

      case DioExceptionType.badCertificate:
        return 'Security certificate error. Please try again.';

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') == true) {
          return 'Network connection failed. Please check your internet and try again.';
        }
        return _extractErrorMessage(error.response?.data) ??
            'An unexpected error occurred. Please try again.';

      default:
        return _extractErrorMessage(error.response?.data) ??
            'Something went wrong. Please try again.';
    }
  }

  static String _handleForbiddenError(dynamic responseData) {
    final message = _extractErrorMessage(responseData);

    if (kDebugMode) {
      print('🚨 ErrorHandler: Handling forbidden error');
      print('🚨 ErrorHandler: Extracted message: $message');
    }

    // Handle specific 403 cases
    if (message?.toLowerCase().contains('already registered') == true ||
        message?.toLowerCase().contains('user already exists') == true) {
      return 'This email is already registered. Please try signing in instead.';
    }

    if (message?.toLowerCase().contains('email not verified') == true ||
        message?.toLowerCase().contains('verify your email') == true) {
      return 'Please verify your email before signing in.';
    }

    return message ?? 'Access denied. Please check your credentials.';
  }

  static String? _extractErrorMessage(dynamic responseData) {
    if (kDebugMode) {
      print('🚨 ErrorHandler: Extracting error message from: $responseData');
    }

    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ??
          responseData['error'] ??
          responseData['msg'];

      if (kDebugMode) {
        print('🚨 ErrorHandler: Extracted message: $message');
      }

      return message;
    }
    return null;
  }

  static bool isUserAlreadyExists(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      final rawMessage =
          _extractErrorMessage(error.response?.data)?.toLowerCase() ?? '';

      // Direct match on the exception message thrown by the data source
      if (error.message?.toLowerCase().contains('already registered') == true ||
          error.message?.toLowerCase().contains('user already exists') ==
              true) {
        return true;
      }

      if (statusCode == ApiConstants.forbidden) {
        // 403 = duplicate detected in registerUser / resendRegisterOtp.
        // "If this email is registered..." is the backend's generic duplicate
        // signature — the account already exists.
        return rawMessage.contains('already registered') ||
            rawMessage.contains('user already exists') ||
            rawMessage.contains('if this email is registered');
      }

      // 400/409 — only explicit verified-account signatures qualify.
      // Never bare "already"/"exist" or unqualified "already exists"
      // substrings: "email does not exist", "OTP already sent", or a
      // non-account duplicate such as "phone number already exists" must
      // NOT redirect the user to Sign In.
      if (statusCode == ApiConstants.badRequest ||
          statusCode == ApiConstants.conflict) {
        if (rawMessage.contains('already verified and registered') ||
            rawMessage.contains('user already verified and registered') ||
            rawMessage.contains('email already exists') ||
            rawMessage.contains('user already exists') ||
            rawMessage.contains('account already exists')) {
          return true;
        }
        final data = error.response?.data;
        if (data is Map<String, dynamic>) {
          final user = data['user'];
          if (user is Map<String, dynamic> &&
              user['isEmailVerified'] == true) {
            return true;
          }
          if (data['isEmailVerified'] == true) return true;
        }
      }
    }
    return false;
  }
}
