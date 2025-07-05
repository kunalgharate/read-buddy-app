// features/books/domain/use cases/get_books.dart
import 'package:injectable/injectable.dart';
import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

/// Param class for SignIn use case
class SignInGoogleParams {
  final String token;

  SignInGoogleParams({
    required this.token,
  });
}

/// SignIn use case
@injectable
class SignInWithGoogle {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  Future<AppUser> call(SignInGoogleParams params) async {
    final user = await repository.signInUsingGoogle(token: params.token);
    return user;
  }
}
