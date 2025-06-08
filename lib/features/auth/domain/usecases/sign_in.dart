// features/books/domain/usecases/get_books.dart
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

  Future<AppUser> call(SignInParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}
