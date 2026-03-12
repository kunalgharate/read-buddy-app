// lib/core/error/failures.dart
abstract class Failure {
  final String message;

  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  NetworkFailure() : super('No Internet Connection');
}

class CancelledFailure extends Failure {
  CancelledFailure() : super('Request cancelled');
}

class UnknownFailure extends Failure {
  UnknownFailure() : super('Unexpected error occurred');
}
