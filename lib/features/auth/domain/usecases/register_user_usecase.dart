import 'package:injectable/injectable.dart';

import '../repositories/auth_repository.dart';

/// Register use case — returns the registered email used for the OTP screen.
@injectable
class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<String> call(Map<String, dynamic> data) =>
      repository.registerUser(data);
}
