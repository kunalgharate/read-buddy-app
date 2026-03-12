// lib/core/error/exception_handler.dart
import 'package:dio/dio.dart';
import 'failure.dart';

class ExceptionHandler {
  static Failure handle(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure();

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data['message'] ?? 'Server error';
        return ServerFailure('[$statusCode] $message');

      case DioExceptionType.cancel:
        return CancelledFailure();

      case DioExceptionType.unknown:
      default:
        return UnknownFailure();
    }
  }
}
