import 'package:injectable/injectable.dart';

import '../entities/app_user.dart';
import '../repositories/auth_repository.dart';

/// SignIn use case
@injectable
class RegisterUserUseCase {
  final AuthRepository repository;

  RegisterUserUseCase(this.repository);

  Future<AppUser> call(Map<String, dynamic> data) =>
      repository.registerUser(data);
}
