import 'package:injectable/injectable.dart';

import 'package:read_buddy_app/features/auth/domain/entities/app_user.dart';
import 'package:read_buddy_app/features/auth/domain/repositories/auth_repository.dart';

/// SignIn use case
@injectable
class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<AppUser> call(String email, String code) =>
      repository.verifyEmail(email, code);
}
