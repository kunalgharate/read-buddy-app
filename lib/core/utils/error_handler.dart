import 'package:dio/dio.dart';
import '../network/api_constants.dart';

class ErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    }
    return error.toString();
  }

  static String _handleDioError(DioException error) {
    switch (error.response?.statusCode) {
      case ApiConstants.badRequest:
        return _extractErrorMessage(error.response?.data) ?? 
               'Invalid request. Please check your input.';
      
      case ApiConstants.unauthorized:
        return 'Session expired. Please login again.';
      
      case ApiConstants.forbidden:
        return _handleForbiddenError(error.response?.data);
      
      case ApiConstants.notFound:
        return 'Resource not found.';
      
      case ApiConstants.conflict:
        return _extractErrorMessage(error.response?.data) ?? 
               'This resource already exists.';
      
      case ApiConstants.internalServerError:
        return 'Server error. Please try again later.';
      
      default:
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout) {
          return 'Connection timeout. Please check your internet connection.';
        }
        if (error.type == DioExceptionType.connectionError) {
          return 'No internet connection. Please check your network.';
        }
        return 'Something went wrong. Please try again.';
    }
  }

  static String _handleForbiddenError(dynamic responseData) {
    final message = _extractErrorMessage(responseData);
    
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
    if (responseData is Map<String, dynamic>) {
      return responseData['message'] ?? 
             responseData['error'] ?? 
             responseData['msg'];
    }
    return null;
  }

  static bool isUserAlreadyExists(dynamic error) {
    if (error is DioException && error.response?.statusCode == ApiConstants.forbidden) {
      final message = _extractErrorMessage(error.response?.data)?.toLowerCase();
      return message?.contains('already registered') == true ||
             message?.contains('user already exists') == true;
    }
    return false;
  }
}
