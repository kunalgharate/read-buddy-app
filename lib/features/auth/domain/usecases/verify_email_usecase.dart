
import 'package:injectable/injectable.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// SignIn use case
@injectable
class VerifyEmailUseCase {
  final AuthRepository repository;

  VerifyEmailUseCase(this.repository);

  Future<AppUser> call(String email, String code) => repository.verifyEmail(email, code);
}
