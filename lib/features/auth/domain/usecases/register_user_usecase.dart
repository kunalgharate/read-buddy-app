import 'package:injectable/injectable.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// Register use case — returns the registered user so the OTP screen can be
/// addressed with the email the backend stored.
@injectable
class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<AppUser> call(Map<String, dynamic> data) =>
      repository.registerUser(data);
}
