// features/books/domain/usecases/get_books.dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

/// Param class for SignIn use case
class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });
}

/// SignIn use case
@injectable
class SignIn {
  final AuthRepository repository;

  SignIn(this.repository);

  Future<AppUser> call(SignInParams params) async {
    if (kDebugMode) {
      print('🎯 SignIn UseCase: Starting sign in');
      print('🎯 SignIn UseCase: Email: ${params.email}');
    }

    try {
      final result = await repository.signIn(
        email: params.email,
        password: params.password,
      );

      if (kDebugMode) {
        print('🎯 SignIn UseCase: Repository call successful');
        print('🎯 SignIn UseCase: User received: ${result.name}');
      }

      return result;
    } catch (error) {
      if (kDebugMode) {
        print('🎯 SignIn UseCase: Repository call failed');
        print('🎯 SignIn UseCase: Error: $error');
      }
      rethrow;
    }
  }
}
