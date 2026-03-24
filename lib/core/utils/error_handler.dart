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

    if (message?.toLowerCase().contains('email not verified') == true) {
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
    if (error is DioException &&
        error.response?.statusCode == ApiConstants.forbidden) {
      final message = _extractErrorMessage(error.response?.data)?.toLowerCase();
      return message?.contains('already registered') == true ||
          message?.contains('user already exists') == true;
    }
    return false;
  }
}
