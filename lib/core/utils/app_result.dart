// lib/core/utils/app_result.dart

/// Simple Result class for handling success/failure responses
sealed class AppResult<T> {
  const AppResult();
  
  /// Returns true if the result is a success
  bool get isSuccess => this is AppSuccess<T>;
  
  /// Returns true if the result is a failure
  bool get isFailure => this is AppFailure<T>;
  
  /// Returns the success value or null
  T? get data => isSuccess ? (this as AppSuccess<T>).data : null;
  
  /// Returns the error message or null
  String? get error => isFailure ? (this as AppFailure<T>).error : null;
  
  /// Executes a function based on the result type
  R fold<R>(
    R Function(T data) onSuccess,
    R Function(String error) onFailure,
  ) {
    return switch (this) {
      AppSuccess(data: final data) => onSuccess(data),
      AppFailure(error: final error) => onFailure(error),
    };
  }
  
  /// Maps the success value if present
  AppResult<R> map<R>(R Function(T) transform) {
    return switch (this) {
      AppSuccess(data: final data) => AppSuccess(transform(data)),
      AppFailure(error: final error) => AppFailure(error),
    };
  }
}

/// Represents a successful result
final class AppSuccess<T> extends AppResult<T> {
  const AppSuccess(this.data);
  
  @override
  final T data;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSuccess<T> && data == other.data;
  
  @override
  int get hashCode => data.hashCode;
  
  @override
  String toString() => 'AppSuccess($data)';
}

/// Represents a failed result
final class AppFailure<T> extends AppResult<T> {
  const AppFailure(this.error);
  
  @override
  final String error;
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFailure<T> && error == other.error;
  
  @override
  int get hashCode => error.hashCode;
  
  @override
  String toString() => 'AppFailure($error)';
}

/// Extension methods for easier Result handling
extension AppResultExtensions<T> on AppResult<T> {
  /// Returns the success value or throws an exception
  T getOrThrow() {
    return switch (this) {
      AppSuccess(data: final data) => data,
      AppFailure(error: final error) => throw Exception(error),
    };
  }
  
  /// Returns the success value or a default value
  T getOrElse(T defaultValue) {
    return switch (this) {
      AppSuccess(data: final data) => data,
      AppFailure() => defaultValue,
    };
  }
  
  /// Returns the success value or the result of a function
  T getOrElseGet(T Function() defaultValue) {
    return switch (this) {
      AppSuccess(data: final data) => data,
      AppFailure() => defaultValue(),
    };
  }
}

/// Convenience functions for creating Results
AppResult<T> success<T>(T data) => AppSuccess(data);
AppResult<T> failure<T>(String error) => AppFailure(error);

/// Async Result extensions
extension FutureAppResultExtensions<T> on Future<AppResult<T>> {
  /// Maps the success value asynchronously
  Future<AppResult<R>> mapAsync<R>(Future<R> Function(T) transform) async {
    final result = await this;
    return switch (result) {
      AppSuccess(data: final data) => AppSuccess(await transform(data)),
      AppFailure(error: final error) => AppFailure(error),
    };
  }
  
  /// Chains another async operation if successful
  Future<AppResult<R>> flatMapAsync<R>(
    Future<AppResult<R>> Function(T) transform,
  ) async {
    final result = await this;
    return switch (result) {
      AppSuccess(data: final data) => await transform(data),
      AppFailure(error: final error) => AppFailure(error),
    };
  }
}
